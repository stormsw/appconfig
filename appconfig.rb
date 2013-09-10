require 'nokogiri'
require 'thor'


module AppConfigCLI
	class Appconfig < Thor
		
		desc "info FileName", "Configuration Info of FileName"
		method_option	:filename, 								
								:default => "app.config", 
								:aliases => "-i",
								:desc => "Configuration file path"
		def info(filename)
			doc = Nokogiri::XML(File.open(filename)) do |config|
			# NOBLANKS - Remove blank nodes
			# NOENT - Substitute entities
			# NOERROR - Suppress error reports
			# STRICT - Strict parsing; raise an error when parsing malformed documents
			# NONET - Prevent any network connections during parsing. Recommended for parsing untrusted documents.
			  config.strict.nonet
			end

			#print doc.to_s
			#wizards = doc.css("Wizards wizard")
			wizards = doc.xpath('//wizard')
			puts "Found #{wizards.count}'s wizards sections document wide."

			editors_names_usage = Hash.new { |h, k| h[k] = 0 }
			editors = doc.xpath('//editor')

			puts "Found #{editors.count}'s editors sections document wide."

			editors.each do |editor|
			#  puts editor.attributes.inspect
			#  exit
			  clear_name = editor[:name].split(':').first
			  editors_names_usage[clear_name] += 1
			end

			puts editors_names_usage.inspect
			
		end 
#		desc "remote SUBCOMMAND ...ARGS", "manage set of tracked repositories"
#		subcommand "remote", Remote	
	end
end

AppConfigCLI::Appconfig.start