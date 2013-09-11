require 'nokogiri'
require 'thor'

module AppConfigCLI
	class Appconfig < Thor		
		@doc=nil
		public	
			class_option :verbose, :type => :boolean, :default => false, :aliases=>'-v'
			
			desc "info", "Configuration Info from FileName."
			def info(filename)
				@doc = readFile(filename)
				#wizards = doc.css("Wizards wizard")	#css selectors can be in use
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
			  hash = Hash.new {|h,k|h[k]={}} 
			  workers.each do |worker|
			    stages = worker[:stages].split(',').uniq
			    registries = worker[:registries].split(',').uniq
			    assembly = worker[:assembly]
			    type = worker[:type]
			    stages.each do |stage|
			      puts "Dupped stage #{stage}:\n\t\t#{worker.to_s}" if hash.keys.include?(stage)
			      hash[stage] = {:assembly=>assembly, :registries => registries, :type=>type }			      
  				end #end stages
			  end
			  puts hash.inspect
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
					#cnt = 1
					
					wizard_spec.each do |wizard|						
						#puts "Row start: #{cnt}"
						stages = wizard[:stages].split(',');					
						meta = wizard[:meta];
						#puts "Analize meta=#{meta} with stages=#{wizard[:stages]}."					
						puts "Analize err: \n #{wizard.to_s}." unless meta
						
						skip = false;											
						
						stages.each do |stage|
							if(stages_transactions.has_key?(stage))
								if(meta.nil?)
									puts "Analize err: \n #{wizard.to_s}."
								end

								raise Exception() unless meta 
								if stageAccepatable(meta,trcode,nil) && (options[:show_dups]||options[:verbose])
									puts "Warning! Stage #{stage} is redefined for #{trcode}"
									puts ">>Details: #{wizard.to_s}"
									puts "Wizard meta=#{meta} with stages=#{wizard[:stages]} skipped."
								else
								
								end
								skip = true;
							end
						end					
						
						next if skip					
						
						raise Exception() unless meta
						
						if stageAccepatable(meta,trcode,nil)
							editors = wizard.css('editor')
							editors_names = []
							editors.each {|editor|
								clear_name = editor[:name].split(':').first
								editors_names<<clear_name
							}
							stages.each{|stage| stages_transactions[stage] = {:editors=>editors_names, :meta =>meta} }						
						end					
						#puts "Row end: #{cnt}"
						#cnt+=1
					end
					
					puts "Configured stages for transaction #{trcode}:"
					stages_transactions.each do |key, val| 
						puts "\t\t#{key}"
						puts "\t\t\tmeta: #{val[:meta]}" if options[:show_meta]
						#val[:editors].each{|ed| puts "\t\t\t\t#{ed}"}
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
			
			def stageAccepatable(meta,code,knownTransactionMeta=nil)
				metacode,trlist = meta.split(';')
				if(metacode=='all')  
					return trlist.split(',').include?(code)
				else 
					if knownTransactionMeta					
						return knownTransactionMeta.to_i==metacode.to_i
					end
				end
				return false;				
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