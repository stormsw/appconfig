require 'nokogiri'
require 'thor'
require 'digest/sha1'
require 'pp'
require "appconfig/version"

module Appconfig
	class Appconfig < Thor		
		@doc=nil
		@transactionMetaData = Hash.new
		@@tr_meta_path = 'data/ugmn/transactions.metadata'
		
		public	
			class_option :verbose, :type => :boolean, :default => false, :aliases=>'-v'
			#class_option :ignore_case, :type => :boolean, :default => true, :aliases=>'-i'			
			desc "info <filename>", "Configuration Info from FileName."
			def info(filename)
				@doc = readFile(filename)
				#wizards = @doc.css("Wizards wizard")	#css selectors can be in use
				wizards = @doc.xpath('//wizard') #xpath allowed aswell
				puts "Found #{wizards.count}'s wizards sections document wide."

				editors_names_usage = Hash.new { |h, k| h[k] = 0 }
				editors = @doc.xpath('//editor')

				puts "Found #{editors.count}'s editors sections document wide."
				editors.each do |editor|
				#  puts editor.attributes.inspect
				#  if include? "name"
				  clear_name = editor[:name].split(':').first
				  editors_names_usage[clear_name] += 1
				end				
				puts '=================================='
				puts "\tTotal\t\tEditor\n"
				
				editors_names_usage.each { |k,v|
					puts "\t#{v}\t\t#{k}"
				}				
				puts '=================================='				
			end 
			
			desc "normalize <filename>", "Split workers by single transaction and stage"
			def normalize(filename)
				@doc = readFile(filename)
				wizards = @doc.xpath('/configuration/Wizards/wizard');
				puts "There is found #{wizards.count} wizard(s)." if options[:verbose]
				tr_codes = Hash.new{|k,v|k[v]=[]}
				transaction_stages = Hash.new{|k,v|k[v]=[]}
				#editorsBigHash = Hash.new				
				#loadMetaData				
				wizards.each do |wizard|
					stages_csv = wizard[:stages]
					stages = stages_csv.split(',').uniq
					assembly = wizard[:assembly]
					m_code,tr_csv = wizard[:meta].split(';')
					trlist = tr_csv.split(',').uniq
					lefttr = trlist.sort
					
					if (trlist.count>1) ||(stages.count>1) #otherwise it already optimized
						normalized = []
						trlist.each do |code|
							#collect described transaction codes
							unless tr_codes[code] && tr_codes[code].any?{|item| item[:assembly]==assembly && item[:code]==m_code}
								tr_codes[code]<<{:assembly=>assembly, :code=>m_code}
							end							
							stages.each do |stage|
								#if there were such stage, wizard will be skipped by app
								unless transaction_stages[code].include?(stage)
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
						normalized.each{|item|wizard.before(item)}
						wizard.remove
					else
					  code = trlist.at(0)
					  stage = stages.at(0)
					  transaction_stages[code]<<stage
					end
				end
				#puts tr_codes.inspect
				pp tr_codes
				known_tr = tr_codes.keys.count
				--known_tr if tr_codes.keys.include?('all')
				puts "Known transaction codes: #{known_tr}" if options[:verbose]
				writeFile(filename+".xml")
			end
			
			desc "workers <filename>","List of registered workers"
			method_option :group_by, :aliases=>'-g', :desc=>'Group by criteria: [assembly, registry, type]'
			def workers(filename)
			  @doc = readFile(filename)
			  workers = @doc.xpath('/configuration/Workers/worker');
			  puts "There is found #{workers.count} worker(s)." if options[:verbose]
			  
			  hashStages = Hash.new {|h,k|h[k]=0} 
			  hashRegistries = Hash.new {|h,k|h[k]=0} 
			  hashAssemblies = Hash.new {|h,k|h[k]=0} 
			  hashTypes = Hash.new {|h,k|h[k]=0}
			  
			  workers.each do |worker|
			    stages = worker[:stages].split(',').uniq
			    registries = worker[:registries].split(',').uniq
			    assembly = worker[:assembly]
			    type = worker[:type]
  				
  				stages.each do |stage|
  			      puts "Duplicated stage #{stage}:\n\t\t#{worker.to_s}" if (hashStages.keys.include?(stage)) && options[:verbose]
  			      hashStages[stage] +=1 #{:assembly=>assembly, :registries => registries, :type=>type }			      
    			end #end stages
  				registries.each{|registry| hashRegistries[registry]+=1}				
  				hashAssemblies[assembly]+=1
  				hashTypes[type]+=1
			  end

			  puts "Declared registires: #{hashRegistries.count}"			  
			  hashRegistries.each do |key,val|
				  puts "\t#{key}"
			  end

			  puts "Declared types: #{hashTypes.count}"
			  hashTypes.each do |key,val|
				  puts "\t#{key}"
			  end

			  puts "Declared assemblies: #{hashAssemblies.count}"			  			  
			  hashAssemblies.each do |key,val|
				  puts "\t#{key}"
			  end
 			  
			  if options[:group_by]
			    puts "\tStages by #{options[:group_by]}"
			   hashGroup = Hash.new {|h,k| h[k]=[]}
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
				 workers.each{|worker| hashGroup[worker[group_key]]+=worker[:stages].split(',')} if group_key
				 hashGroup.each do |key,val|
           puts "\t[#{key}]" 
           val.sort.each{|stage| puts "\t\t#{stage}"}            
         end
				else
          puts "Declared stages: #{hashStages.count}"
          hashStages.each do |key,val|
            puts "\t#{key}#{"\t<<Check count: #{val}" if val>1}"
          end
				end			 
			end
			
			desc "stages <filename> <transaction code> [options]", "List configured stages for <transaction code> from <filename>"
			method_option :show_dups, :type => :boolean, :aliases=> '-d', :desc=>'Verbose output of XML block when given stage already parsed.'
			method_option :show_editors, :type => :boolean, :aliases=> '-e', :desc=>'Print editors for each stage.'
			method_option :show_meta, :type => :boolean, :aliases=> '-m', :desc=>'Print wizard configuration meta.'
			def stages(filename,trcode)
				@doc = readFile(filename);
				wizards = @doc.xpath('/configuration/Wizards') 
				puts "Found #{wizards.count}'s Wizards sections from root." if options[:verbose]
				
				if wizards
					stages_transactions = Hash.new {|hash, key| hash[key] = []}
					wizard_spec = wizards.css('wizard')
					puts "Found #{wizard_spec.count}'s Wizards sections from root." if options[:verbose]

					wizard_spec.each do |wizard|						
						stages = wizard[:stages].split(',');					
						meta = wizard[:meta];
						unless meta 
							puts "Analize error: \n #{wizard.to_s}." if options[:verbose]
							#raise "Incorrect meta section (null)"
							next
						end
						skip = false;											
						
						stages.each do |stage|
							if(stages_transactions.has_key?(stage))
								if wizardMetaAccepatable(meta,trcode,nil) && (options[:show_dups]||options[:verbose])
									puts "Warning! Stage #{stage} is redefined for #{trcode}"
									puts ">>Details: #{wizard.to_s}"
									puts "Wizard meta=#{meta} with stages=#{wizard[:stages]} skipped."
								end
								skip = true;
							end
						end											

						next if skip					

						if wizardMetaAccepatable(meta,trcode,nil)
							editors = wizard.css('editor')
							editors_names = []
							editors.each {|editor|
								clear_name = editor[:name].split(':').first
								editors_names<<clear_name
							}
							stages.each{|stage| stages_transactions[stage] = {:editors=>editors_names, :meta =>meta} }						
						end
					end					
					puts "Configured stages for transaction #{trcode}:"
					stages_transactions.each do |key, val| 
						puts "\t\t#{key}"
						puts "\t\t\tmeta: #{val[:meta]}" if options[:show_meta]						
						val[:editors].each{|ed| puts "\t\t\t\t#{ed}"} if options[:show_editors]
					end
				else
					puts "ERROR: invalid config file. Wizards section not found"
				end
			end
	
      def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
        @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
        super(argv)
        #STDERR.puts Dir.pwd
      end
      
    no_commands do      
      def execute!
        # your code here, assign a value to exitstatus         
        #exitstatus = 
        Appconfig.start(@argv)
        
        #????Appconfig.new(@argv).invoke
        
        #method(:start).call ARGV
          #0
         #invoke('start',ARGV)
          #self.start(@argv)
          #Appconfig::Appconfig.start(@argv)
          #Appconfig::Appconfig.start(ARGV)
        #@kernel.exit(exitstatus)
      end
      #remove_command :execute!
      def this_is_not_a_command
      end
    end
    
		private
			def loadMetaData()
				puts "Load: #{@@tr_meta_path}"
				@transactionMetaData = Hash.new
				File.open(@@tr_meta_path).each do |record|
					record.sub!(/#.+$/,'')					
					code,m_code = record.scan(/\w+/) if record
					@transactionMetaData[code]=m_code
				end
			end
			
			def getTransactionMetaCode(code)
				@transactionMetaData[code]
			end
			
			# Check code against meta
			# meta can be: all;all or all;<csv> or <(metacode)\d+>;<csv>
			# when metacode is not "all" - need to compare with knownTransactionMeta
			# returns true when <csv> contains code and knownMeta is nil or equal metacode
			def wizardMetaAccepatable(meta,code,knownTransactionMeta=nil)
				#puts "Meta: "+meta
				metacode,trlist = meta.split(';')
				# currently this check in application is case insensitive				
				accepted = trlist.split(',').any?{ |s| s.casecmp(code)==0 }# trlist.split(',').include?(code)
				unless(metacode=='all')
					if knownTransactionMeta
						accepted &&= knownTransactionMeta.to_i==metacode.to_i
					else
						accepted = false
					end
				end				
				return accepted;				
			end
			
			def writeFile(fileName)
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
				f = File.open(fileName,"w")
				#.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
				#, :save_with => FORMAT | AS_XML
				@doc.write_xml_to(f,:encoding => 'UTF-8',:indent_text =>' ',:indent => 2,:save_with =>Nokogiri::XML::Node::SaveOptions::AS_XML)
				f.close
				puts "Check:#{fileName}"
				#File.open("out_" + filename, 'w') {|f| f.write(@doc.to_xml) }
			end
			
			def readFile(fileName)
				doc = Nokogiri::XML(File.open(fileName)) do |config|
					# NOBLANKS - Remove blank nodes
					# NOENT - Substitute entities
					# NOERROR - Suppress error reports
					# STRICT - Strict parsing; raise an error when parsing malformed documents
					# NONET - Prevent any network connections during parsing. Recommended for parsing untrusted documents.
				  config.strict.nonet
				end
				return doc
			end
	end
end
#debug
#Appconfig::Appconfig.start(ARGV)