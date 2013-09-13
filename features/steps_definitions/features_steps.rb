require 'nokogiri'
require 'aruba/api'
#require 'aruba/cucumber/hooks'
#require 'aruba/reporting'
#World(Aruba::Api)

Given(/^I have "(.*?)" in data:$/) do |filename,xml|
	@filename = "data/"+filename
	#STDERR.puts string  
	File.open(@filename, 'w') {|f| f.write(xml) }
end

When(/^I normalize "(.*?)"$/) do |filename|
  cmd = 'appconfig.cmd normalize data/'+filename
  run_simple(unescape(cmd))
  assert_exit_status(0)
end

Then(/^"(.*?)" produced in data:$/) do |filename|
	filename = "data/"+filename
	File.file?(filename).should == true
end

Then(/^"(.*?)" contains (\d+) wizards with stage in "(.*?)"$/) do |filename,wcount,wnames|
	doc = Nokogiri::XML(File.open('data/'+filename)) do |config|
					# NOBLANKS - Remove blank nodes
					# NOENT - Substitute entities
					# NOERROR - Suppress error reports
					# STRICT - Strict parsing; raise an error when parsing malformed documents
					# NONET - Prevent any network connections during parsing. Recommended for parsing untrusted documents.
				  config.strict.nonet
				end
	wizards = doc.xpath('//wizard')
	wizards.count.should==wcount.to_i
	stages=[]
	wizards.each{|w|stages<<w[:stages]}
	wnames.split(',').each{|name| stages.include?(name).should==true}
end

Then(/^"(.*?)" contains (\d+) wizards with transaction in "(.*?)"$/) do |filename,wcount,wnames|
	doc = Nokogiri::XML(File.open('data/'+filename)) do |config|
					# NOBLANKS - Remove blank nodes
					# NOENT - Substitute entities
					# NOERROR - Suppress error reports
					# STRICT - Strict parsing; raise an error when parsing malformed documents
					# NONET - Prevent any network connections during parsing. Recommended for parsing untrusted documents.
				  config.strict.nonet
				end
	wizards = doc.xpath('//wizard')
	wizards.count.should==wcount.to_i
	wizards.each{|w|stages<<w[:stages]}
	wnames.split(',').each do |name| 
		wizards.any? { |w| w[:meta].split(';')[1]==name}.should==true		
	end
end