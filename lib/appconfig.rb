require 'nokogiri'
require 'thor'
require 'digest/sha1'
require 'pp'
require 'appconfig/version'

module Appconfig
  class Appconfig < Thor
    class_option :verbose, :type => :boolean, :default => false, :aliases => '-v'
    #class_option :ignore_case, :type => :boolean, :default => true, :aliases=>'-i'
    @doc=nil
    @transaction_meta_data = Hash.new
    #@@tr_meta_path = 'data/ugmn/transactions.metadata'

    public

    desc 'info <filename>', 'Configuration Info from FileName.'

    def info(filename)
      @doc = read_file(filename)
      #wizards = @doc.css("Wizards wizard")	#css selectors can be in use
      wizards = @doc.xpath('//wizard') #xpath allowed as well
      puts "Found #{wizards.count}'s wizards sections document wide."

      editors_names_usage = Hash.new { |h, k| h[k] = 0 }
      editors = @doc.xpath('//editor')

      puts "Found #{editors.count}'s editors sections document wide."
      editors.each do |editor|
        clear_name = editor[:name].split(':').first
        editors_names_usage[clear_name] += 1 if clear_name
      end
      puts '=================================='
      puts "\tTotal\t\tEditor\n"

      editors_names_usage.each { |k, v|
        puts "\t#{v}\t\t#{k}"
      }
      puts '=================================='
    end

    desc 'optimize <filename>', 'Merge workers by same editors for transaction and stage'

    def optimize(filename)
      @doc = read_file(filename)
      wizards = @doc.xpath('/configuration/Wizards/wizard')
      puts "There is found #{wizards.count} wizard(s)." if options[:verbose]
      transaction_meta = Hash.new
      editors_cache_stat = Hash.new { |k, v| k[v]=0 }
      editors_cache = Hash.new { |k, v| k[v]={} }
      wizards.each do |wizard|
        stages_csv = wizard[:stages]
        stages = stages_csv.split(',').uniq
        assembly = wizard[:assembly]
        m_code, tr_csv = wizard[:meta].split(';')
        wizard_transactions = tr_csv.split(',').uniq
        # should help with specialized meta codes
        transaction_meta[m_code]||=Hash.new { |k, v| k[v]=[] }
        #known_transaction_stages=transaction_meta[m_code]
        editors = wizard.css('editor')
        key = Digest::SHA1.base64digest(editors.to_xml)
        editors_cache_stat[key]+=1
        if editors_cache.keys.include?(key)
          parent = editors_cache[key][:wizard]
          parent_stages = parent[:stages]
          parent_meta = parent[:meta]
          parent_assembly = parent[:assembly]
          parent_m_code, parent_tr_csv = parent_meta.split(';')
          if (parent_m_code==m_code||parent_m_code=='all') && parent_assembly==assembly
            new_stages=(parent_stages.split(',')+stages).uniq.sort.join(',')
            new_trlist = (parent_tr_csv.split(',')+wizard_transactions).uniq.sort.join(',')
            new_meta = "#{parent_m_code};#{new_trlist}"
            parent[:stages]=new_stages
            parent[:meta] = new_meta
            wizard.remove
          else
          end
        else
          new_trlist = wizard_transactions.sort.join(',')
          new_stages = stages.sort.join(',')
          wizard[:stages]=new_stages
          wizard[:meta] ="#{m_code};#{new_trlist}"
          editors_cache[key]={:stat => 1, :xml => editors, :wizard => wizard}
        end
      end

      uq_ed=0
      editors_cache_stat.each do |k, v|
        if v>1
          puts "\t#{v}\tKey: #{k}"
        else
          uq_ed +=1
        end
      end
      sort_wizards(@doc.at('//Wizards'))

      puts "Unique sets: #{uq_ed}" if uq_ed
      write_file(filename+".xml")
      #exit(0)
    end

    desc "normalize <filename>", "Split workers by single transaction and stage"
    method_option :sort, :aliases => '-s', :desc => 'Sort by stage,transaction code'

    def normalize(filename)
      @doc = read_file(filename)
      wizards = @doc.xpath('/configuration/Wizards/wizard')
      puts "There is found #{wizards.count} wizard(s)." if options[:verbose]
      known_transaction_codes = Hash.new { |k, v| k[v]=[] }
      transaction_meta = Hash.new
      known_transaction_stages=Hash.new { |k, v| k[v]=[] }
      #editorsBigHash = Hash.new
      #load_meta_data
      wizards.each do |wizard|
        stages_csv = wizard[:stages]
        stages = stages_csv.split(',').uniq
        assembly = wizard[:assembly]
        meta_type_code, tr_csv = wizard[:meta].split(';')
        wizard_transactions = tr_csv.split(',').uniq
        # should help with specialized meta codes
        #transaction_meta[meta_type_code]||=Hash.new { |k, v| k[v]=[] }
        #known_transaction_stages=transaction_meta[m_code]

        if (wizard_transactions.count>1) ||(stages.count>1) #otherwise it already optimized
          puts "Wizard transactions[#{tr_csv}, meta[#{meta_type_code}]" if options[:verbose]
          normalized_wizards = []
          wizard_transactions.each do |code|
            #collect described transaction codes
            normalizer_process_transactions(assembly, code, known_transaction_codes, meta_type_code, normalized_wizards, stages, known_transaction_stages, wizard)
          end
          normalized_wizards.each { |item| wizard.before(item) }
          wizard.unlink
        else
          code = wizard_transactions.at(0)
          stage = stages.at(0)
          #known_transaction_stages[code]<<stage
          known_transaction_stages[code]<<{:stage => stage, :code => meta_type_code} #stage
          puts "Optimal -> transaction[#{code}].stage[#{stage}]" if options[:verbose]
        end
      end
      #puts @doc.css('wizard').to_xml
      #puts "Sorting:"
      #sort_wizards(@doc.xpath('/configuration/Wizards/wizard'))
      sort_wizards(@doc.at('//Wizards'))
      #puts @doc.css('wizard').to_xml

      known_tr = known_transaction_codes.keys.count
      --known_tr if known_transaction_codes.keys.include?('all')
      puts "Known transaction codes: #{known_tr}" if options[:verbose]
      write_file(filename+".xml")
      #exit(0)
    end

    desc "workers <filename>", "List of registered workers"
    method_option :group_by, :aliases => '-g', :desc => 'Group by criteria: [assembly, registry, type]'

    def workers(filename)
      @doc = read_file(filename)
      workers = @doc.xpath('/configuration/Workers/worker')
      puts "There is found #{workers.count} worker(s)." if options[:verbose]

      hash_stages = Hash.new { |h, k| h[k]=0 }
      hash_registries = Hash.new { |h, k| h[k]=0 }
      hash_assemblies = Hash.new { |h, k| h[k]=0 }
      hash_types = Hash.new { |h, k| h[k]=0 }

      workers.each do |worker|
        stages = worker[:stages].split(',').uniq
        registries = worker[:registries].split(',').uniq
        assembly = worker[:assembly]
        type = worker[:type]

        stages.each do |stage|
          puts "Duplicated stage #{stage}:\n\t\t#{worker.to_s}" if (hash_stages.keys.include?(stage)) && options[:verbose]
          hash_stages[stage] +=1 #{:assembly=>assembly, :registries => registries, :type=>type }
        end #end stages
        registries.each { |registry| hash_registries[registry]+=1 }
        hash_assemblies[assembly]+=1
        hash_types[type]+=1
      end

      puts "Declared registries: #{hash_registries.count}"
      hash_registries.each do |key, val|
        puts "\t#{key}"
      end

      puts "Declared types: #{hash_types.count}"
      hash_types.each do |key, val|
        puts "\t#{key}"
      end

      puts "Declared assemblies: #{hash_assemblies.count}"
      hash_assemblies.each do |key, val|
        puts "\t#{key}"
      end

      if options[:group_by]
        puts "\tStages by #{options[:group_by]}"
        hash_group = Hash.new { |h, k| h[k]=[] }
        group_key = nil
        case options[:group_by].to_sym
          when :assembly
            group_key = :assembly
          when :registry
            group_key = :registries
          when :type
            group_key =:type
          else
            raise "Wrong group criteria specified: #{options[:group_by]}"
        end
        workers.each { |worker| hash_group[worker[group_key]]+=worker[:stages].split(',') } if group_key
        hash_group.each do |key, val|
          puts "\t[#{key}]"
          val.sort.each { |stage| puts "\t\t#{stage}" }
        end
      else
        puts "Declared stages: #{hash_stages.count}"
        hash_stages.each do |key, val|
          puts "\t#{key}#{"\t<<Check count: #{val}" if val>1}"
        end
      end
    end

    desc "stages <filename> <transaction code> [options]", "List configured stages for <transaction code> from <filename>"
    method_option :show_dups, :type => :boolean, :aliases => '-d', :desc => 'Verbose output of XML block when given stage already parsed.'
    method_option :show_editors, :type => :boolean, :aliases => '-e', :desc => 'Print editors for each stage.'
    method_option :show_meta, :type => :boolean, :aliases => '-m', :desc => 'Print wizard configuration meta.'
	method_option :show_line, :type => :boolean, :aliases => '-l', :desc => 'Print configuration line number for wizard.'
	method_option :stage, :aliases => '-s', :desc => 'Filter stage to name'
    def stages(filename, transaction_code)
      @doc = read_file(filename)
      wizards = @doc.xpath('/configuration/Wizards')
      puts "Found #{wizards.count}'s Wizards sections from root." if options[:verbose]

      if wizards
        stages_transactions = Hash.new { |hash, key| hash[key] = [] }
        wizard_spec = wizards.css('wizard')
        puts "Found #{wizard_spec.count}'s Wizards sections from root." if options[:verbose]

        wizard_spec.each do |wizard|
          stages = wizard[:stages].split(',')
          meta = wizard[:meta]
          unless meta
            puts "Analise error: \n #{wizard.to_s}." if options[:verbose]
            #raise "Incorrect meta section (null)"
            next
          end
          skip = false

          stages.each do |stage|
            if stages_transactions.has_key?(stage)
              if wizard_meta_acceptable(meta, transaction_code, nil) && (options[:show_dups]||options[:verbose])
                puts "Warning! Stage #{stage} is redefined for #{transaction_code}"
                puts ">>Details: #{wizard.to_s}"
                puts "Wizard meta=#{meta} with stages=#{wizard[:stages]} skipped."
              end
              skip = true
            end
          end

          next if skip

          if wizard_meta_acceptable(meta, transaction_code, nil)
            editors = wizard.css('editor')
            editors_names = []
            editors.each { |editor|
              clear_name = editor[:name].split(':').first
              editors_names<<clear_name
            }
            stages.each { |stage| stages_transactions[stage] = {:editors => editors_names, :meta => meta, :line => wizard.line } }
          end
        end
        puts "Configured stages for transaction #{transaction_code}:"
        stages_transactions.each do |key, val|
		  if options[:stage] 
			if options[:stage].upcase!=key.upcase
				next
			end
		  end
			line_number = options[:show_line]?val[:line]:''
			puts "\t#{line_number}\t#{key}"
			puts "\t\t\tmeta: #{val[:meta]}" if options[:show_meta]
			val[:editors].each { |ed| puts "\t\t\t\t\t#{ed}" } if options[:show_editors]		 
        end
      else
        raise "ERROR: invalid config file. Wizards section not found"
      end
    end

    private
    def get_transaction_meta_code(code)
      @transaction_meta_data[code]
    end

    # @param [String] assembly (Wizard class name)
    # @param [String] code  (Transaction code, may be 'all')
    # @param [Hash] known_transaction_codes (Cached transactions descriptors)
    # @param [String] meta_type_code (Number that describes transaction metaType or 'all')
    # @param [Nokogiri::XML::NodeSet] normalized (Cached array of prepared wizards)
    # @param [Array] wizard_stages (stages section from wizard)
    # @param [Hash] known_transaction_stages (cached transaction stages)
    # @param [Nokogiri::XML::Node] wizard (back ref to wizard, for nodes operation)
    def normalizer_process_transactions(assembly, code, known_transaction_codes, meta_type_code, normalized, wizard_stages, known_transaction_stages, wizard)
      # will not add to cache if it contains record for transaction in same assembly and metaType (i.m we will have N and 'all' members for some transactions)
      unless known_transaction_codes[code] && known_transaction_codes[code].any? { |item| item[:assembly]==assembly && item[:code]==meta_type_code }
        known_transaction_codes[code]<<{:assembly => assembly, :code => meta_type_code}
        puts "Added #{code} to known with assembly:#{assembly};code:#{meta_type_code} " if options[:verbose]
      end

      wizard_stages.each do |stage|
        normalizer_process_stages(code, meta_type_code, normalized, stage, known_transaction_stages, wizard)
      end
    end

    # @param [String] trans_code
    # @param [String] meta_type_code
    # @param [Nokogiri::XML::NodeSet] normalized_wizards
    # @param [String] stage
    # @param [Hash] known_transaction_stages (cached transaction stages configured)
    # @param [Nokogiri::XML::Node] wizard
    def normalizer_process_stages( trans_code, meta_type_code, normalized_wizards, stage_name, known_transaction_stages, wizard)
      puts "working out stage #{stage_name}" if options[:verbose]

      #'all' as transaction code matches any transaction to this stage
      # So,if there were such stage, wizard will be skipped by app
      #skipped_by_all = known_transaction_stages['all'].include?(stage) && trans_code!='all'
      skipped_by_all = known_transaction_stages['all'].any?{|item| item[:stage]==stage_name && item[:code]==meta_type_code } && trans_code!='all'
      if skipped_by_all && options[:verbose]
        puts "Warning: override stage #{stage_name} for transaction #{trans_code} by previous 'all'."
      end

      pp known_transaction_stages if options[:verbose]
      #unless known_transaction_codes[code] && known_transaction_codes[code].any? { |item| item[:assembly]==assembly && item[:code]==meta_type_code }
      #unless known_transaction_stages[trans_code].include?(stage)||skipped_by_all
      unless skipped_by_all || known_transaction_stages[trans_code]&&known_transaction_stages[trans_code].any?{ |item|
          item[:stage]==stage_name&&
              item[:code]==meta_type_code}
        #known_transaction_codes[code]<<{:assembly => assembly, :code => meta_type_code}
        known_transaction_stages[trans_code]<<{:stage => stage_name, :code => meta_type_code} #stage

        puts "new wizard!" if options[:verbose]
        #we will not modify there, validation check should be done separately
        #if wizardMetaAccepatable(wizard[:meta],code,getTransactionMetaCode(code))

        #normalizer should remove all found codes and processed stages
        new_wizard = wizard.dup()
        new_wizard[:meta] = "#{meta_type_code};#{trans_code}"
        new_wizard[:stages] = stage_name

        #editors = new_wizard.css('editor')
        #key = Digest::SHA1.base64digest(editors.to_xml)
        #editorsBigHash[key]=editors

        normalized_wizards<<new_wizard
      end
    end

    # Check code against meta
    # meta can be: all;all or all;<csv> or <(meta-code)\d+>;<csv>
    # when meta-code is not "all" - need to compare with knownTransactionMeta
    # returns true when <csv> contains code and knownMeta is nil or equal meta-code
    def wizard_meta_acceptable(meta, code, known_meta=nil)
      meta_code, tr_list = meta.split(';')
      # currently this check in application is case insensitive
      accepted = tr_list=='all'|| tr_list.split(',').any? { |s| s.casecmp(code)==0 } # tr_list.split(',').include?(code)
      unless meta_code=='all'
        if known_meta
          accepted &&= known_meta.to_i==meta_code.to_i
        else
          accepted = false
        end
      end
      return accepted
    end

    def write_file(filename)
      # SaveOptions
      # AS_BUILDER: Save builder created document
      # AS_HTML: Save as HTML
      # AS_XHTML: Save as XHTML
      # AS_XML: Save as XML
      # DEFAULT_HTML: the default for HTML document
      # DEFAULT_XHTML: the default for XHTML document
      # DEFAULT_XML: the default for XML documents
      # FORMAT: Format serialized xml
      # NO_DECLARATION: Do not include declarations
      # NO_EMPTY_TAGS: Do not include empty tags
      # NO_XHTML: Do not save XHTML
      # e.g. node.write_to(io, :encoding => 'UTF-8', :indent => 2)

      f = File.open(filename, 'w')
      # TODO find how to save formatted data
      #.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
      #, :save_with => FORMAT | AS_XML
      @doc.write_xml_to(f, :encoding => 'UTF-8', :indent_text => ' ', :indent => 2, :save_with => Nokogiri::XML::Node::SaveOptions::FORMAT)
      f.close
      #puts "Check:#{filename}"
    end

    def read_file(filename)
      doc = Nokogiri::XML(File.open(filename)) do |config|
        # NOBLANKS - Remove blank nodes
        # NOENT - Substitute entities
        # NOERROR - Suppress error reports
        # STRICT - Strict parsing; raise an error when parsing malformed documents
        # NONET - Prevent any network connections during parsing. Recommended for parsing untrusted documents.
        config.strict.noblanks.nonet
      end
      return doc
    end

    #@param wizard [Nokogiri::XML::Node]
    def wizard_to_hash(wizard)
      stages_csv = wizard[:stages].split(',').sort.uniq.join(',')
      assembly = wizard[:assembly]
      meta_code, tr_csv = wizard[:meta].split(';')
      tr_csv = tr_csv.split(',').sort.uniq.join(',')
      return {:stages => stages_csv, :assembly => assembly, :meta_code => meta_code, :transaction => tr_csv}
    end
=begin

    I would like to have there something like this

    stages, meta; codes

    stages[X]
      meta[all; codes<>all]
      meta[<>all,codes<>all]
      meta[<>all,all]
      meta[all,all]
    stages[all]
      meta[all; codes<>all]
      meta[<>all,codes<>all]
      meta[<>all,all]
      meta[all,all]

=end
  def compare2(a,b)

    stage_a_all = a[:stages]=='all'
    stage_b_all = b[:stages]=='all'

    meta_a_all = a[:meta_code]=='all'
    meta_b_all = b[:meta_code]=='all'

    codes_a_all = a[:transaction] == 'all'
    codes_b_all = b[:transaction] == 'all'

    if(a[:stages]!=b[:stages])
      return -1 if(stage_a_all&&!stage_b_all)
      return 1 if(!stage_a_all&&stage_b_all)
      return a[:stages].to_s <=> b[:stages].to_s
    end

    a_type1 = meta_a_all && !codes_a_all
    b_type1 = meta_b_all && !codes_b_all

    a_type2 = !meta_a_all && !codes_a_all
    b_type2 = !meta_b_all && !codes_b_all

    a_type3 = !meta_a_all && codes_a_all
    b_type3 = !meta_b_all && codes_b_all

    a_type4 = meta_a_all && codes_a_all
    b_type4 = meta_b_all && codes_b_all

    if(a[:meta_code]!=b[:meta_code])
      return 1 if(a_type1 && !b_type1)
      return -1 if(!a_type1 && b_type1)

      return 1 if(a_type2 && (b_type3||b_type4))
      return -1 if(b_type2 && (a_type3||a_type4))

      return 1 if(a_type3 && b_type4)
      return -1 if(b_type3 && a_type4)
    end



    if(a_type1 && b_type1)

    end

    return 1 if(a_type2 && !b_type2)
    return -1 if(!a_type2 && b_type2)

    return 1 if(a_type3 && !b_type3)
    return -1 if(!a_type3 && b_type3)

    return 0
  end
    # return -1 if a<b |0 if a==b|1 if a>b
    #@param a_wizard [Nokogiri::XML::Node]
    #@param b_wizard [Nokogiri::XML::Node]
    def compare_wizards(a_wizard, b_wizard)
      a = wizard_to_hash(a_wizard)
      b = wizard_to_hash(b_wizard)
      #stages csv gives max  (all=MIN)
      return -1 if (a[:stages] == "all" && b[:stages]!="all")
      return 1 if (a[:stages] != "all" && b[:stages]=="all")
      stc = a[:stages].to_s <=> b[:stages].to_s
      return stc if stc!=0

      #m_code next (all=MIN)
      return -1 if (a[:meta_code] == "all" && b[:meta_code]!="all")
      return 1 if (a[:meta_code] != "all" && b[:meta_code]=="all")
      stc = a[:meta_code].to_i <=> b[:meta_code].to_i
      return stc if stc!=0

      #tr_csv
      return -1 if (a[:transaction] == "all" && b[:transaction]!="all")
      return 1 if (a[:transaction] != "all" && b[:transaction]=="all")
      stc = a[:transaction].to_s <=> b[:transaction].to_s
      return stc if stc!=0

      #assembly?
      return a[:assembly].to_s <=> b[:assembly].to_s
    end

    #@param doc [Nokogiri::XML::NodeSet]
    def sort_wizards(doc)

      doc.search('./wizard').sort{ |a_node, b_node| compare_wizards(a_node, b_node) }.each do |w|
        doc<<w
      end

    end

    # this one some how cant update cached nodes?!
    #@param doc [Nokogiri::XML::NodeSet]
    def sort_wizards1(doc)

      if doc.count>0
        #doc.remove #unlink from document

        nodes = doc.sort { |a_node, b_node| compare_wizards(a_node, b_node) }.each do |node|
          node.unlink
          # node
        end

        nodes.each { |node| doc << node }
      end

    end
  end

  class AppconfigRunner

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      Appconfig.start(@argv.dup)
    end
  end

end

#Appconfig::Appconfig.start(ARGV)