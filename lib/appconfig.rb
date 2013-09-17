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

    desc "info <filename>", "Configuration Info from FileName."
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

    desc "normalize <filename>", "Split workers by single transaction and stage"
	method_option :sort, :aliases => '-s', :desc => 'Sort by stage,transaction code'
    def normalize(filename)
      @doc = read_file(filename)
      wizards = @doc.xpath('/configuration/Wizards/wizard')
      puts "There is found #{wizards.count} wizard(s)." if options[:verbose]
      tr_codes = Hash.new { |k, v| k[v]=[] }
	  transaction_meta = Hash.new
      #editorsBigHash = Hash.new
      #load_meta_data
      wizards.each do |wizard|
        stages_csv = wizard[:stages]
        stages = stages_csv.split(',').uniq
        assembly = wizard[:assembly]
        m_code, tr_csv = wizard[:meta].split(';')
        wizard_transactions = tr_csv.split(',').uniq
		# should help with specialized meta codes
		transaction_meta[m_code]||=Hash.new { |k, v| k[v]=[] }
		transaction_stages=transaction_meta[m_code]

        if (wizard_transactions.count>1) ||(stages.count>1) #otherwise it already optimized
          normalized = []
          wizard_transactions.each do |code|
            #collect described transaction codes
            unless tr_codes[code] && tr_codes[code].any? { |item| item[:assembly]==assembly && item[:code]==m_code }
              tr_codes[code]<<{:assembly => assembly, :code => m_code}
            end
            stages.each do |stage|
              #if there were such stage, wizard will be skipped by app
              skipped_by_all = transaction_stages['all'].include?(stage) && code!='all'
              if skipped_by_all && options[:verbose]
                puts "Warning: override stage #{stage} for transaction #{code} by previous 'all'."
              end
              unless transaction_stages[code].include?(stage)||skipped_by_all
                #we will not modify there, validation check should be done separately
                #if wizardMetaAccepatable(wizard[:meta],code,getTransactionMetaCode(code))
                transaction_stages[code] <<stage
                #normalizer should remove all found codes and processed stages
                new_wizard = wizard.dup(1)
                new_wizard[:meta] = "#{m_code};#{code}"
                new_wizard[:stages] = stage
                #editors = new_wizard.css('editor')
                #key = Digest::SHA1.base64digest(editors.to_xml)
                #editorsBigHash[key]=editors
                normalized<<new_wizard
              end
            end
          end
          normalized.each { |item| wizard.before(item) }
          wizard.remove
        else
          code = wizard_transactions.at(0)
          stage = stages.at(0)
          transaction_stages[code]<<stage
        end
      end
      #pp tr_codes
      known_tr = tr_codes.keys.count
      --known_tr if tr_codes.keys.include?('all')
      puts "Known transaction codes: #{known_tr}" if options[:verbose]
      write_file(filename+".xml")
	  exit(0)
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
            stages.each { |stage| stages_transactions[stage] = {:editors => editors_names, :meta => meta} }
          end
        end
        puts "Configured stages for transaction #{transaction_code}:"
        stages_transactions.each do |key, val|
          puts "\t\t#{key}"
          puts "\t\t\tmeta: #{val[:meta]}" if options[:show_meta]
          val[:editors].each { |ed| puts "\t\t\t\t#{ed}" } if options[:show_editors]
        end
      else
        raise "ERROR: invalid config file. Wizards section not found"
      end
    end
		
	#this requires only for aruba in process testing... and it breaks thor default constructor
    #def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
    #  @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
	  #STDERR.puts self.class.class_options
	  #puts self.class.methods
	  #super(@argv,[self.class.class_options,self.class.method_options].flatern)
      #STDERR.puts Dir.pwd
    #end

    no_commands do
      def execute!
        # your code here, assign a value to exitstatus         
        #exitstatus =
        #Appconfig.start(ARGV)
        self.class.start(ARGV)
		#(@argv)
		#   script = MyScript.new(args, options, config)
		#   script.invoke(:command, first_arg, second_arg, third_arg)
		#args = @argv.dup
		#command = args.shift!.to_sym
		#invoke(command, args)
        #@kernel.exit(exitstatus)
      end
    end

    private
=begin
      #TODO refactor to validator
			def load_meta_data
        puts "Load: #{@@tr_meta_path}"
				@transaction_meta_data = Hash.new
				File.open(@@tr_meta_path).each do |record|
					record.sub!(/#.+$/,'')					
					code,m_code = record.scan(/\w+/) if record
					@transaction_meta_data[code]=m_code  if code
				end
			end

=end
    def get_transaction_meta_code(code)
      @transaction_meta_data[code]
    end

    # Check code against meta
    # meta can be: all;all or all;<csv> or <(metacode)\d+>;<csv>
    # when metacode is not "all" - need to compare with knownTransactionMeta
    # returns true when <csv> contains code and knownMeta is nil or equal metacode
    def wizard_meta_acceptable(meta, code, known_meta=nil)
      #puts "Meta: "+meta
      meta_code, tr_list = meta.split(';')
      # currently this check in application is case insensitive
      accepted = tr_list.split(',').any? { |s| s.casecmp(code)==0 } # tr_list.split(',').include?(code)
      unless meta_code=='all'
        if known_meta
          accepted &&= known_meta.to_i==meta_code.to_i
        else
          accepted = false
        end
      end
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
        config.strict.nonet
      end
    end
  end
end

#Appconfig::Appconfig.start(ARGV)