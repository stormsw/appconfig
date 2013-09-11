require 'nokogiri'
require 'thor'

module AppConfigCLI
	class Appconfig < Thor		
		@doc=nil
		public	
			class_option :verbose, :type => :boolean, :default => false, :aliases=>'-v'
			class_option :ignore_case, :type => :boolean, :default => true, :aliases=>'-i'
			
			desc "info", "Configuration Info from FileName."
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
				
				registries.each{|registry|
					hashRegistries[registry]+=1
				}
				
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
 
			  puts "Declared stages: #{hashStages.count}"
			  
			  hashStages.each do |key,val|
				puts "\t#{key}#{"\t<<Check count: #{val}" if val>1}"
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
								if stageAccepatable(meta,trcode,nil) && (options[:show_dups]||options[:verbose])
									puts "Warning! Stage #{stage} is redefined for #{trcode}"
									puts ">>Details: #{wizard.to_s}"
									puts "Wizard meta=#{meta} with stages=#{wizard[:stages]} skipped."
								end
								skip = true;
							end
						end											

						next if skip					

						if stageAccepatable(meta,trcode,nil)
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
		
		private
			
			def getTransactionMetaCode(code)
				return 'all';
			end
			
			# Check code against meta
			# meta can be: all;all or all;<csv> or <(metacode)\d+>;<csv>
			# when metacode is not "all" - need to compare with knownTransactionMeta
			# returns true when <csv> contains code and knownMeta is nil or equal metacode
			def stageAccepatable(meta,code,knownTransactionMeta=nil)
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

AppConfigCLI::Appconfig.start(ARGV)