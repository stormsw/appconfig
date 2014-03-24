require 'nokogiri'
require 'aruba/api'
#require 'aruba/cucumber/hooks'
#require 'aruba/reporting'
#World(Aruba::Api)

def read_appconfig_xml(filename)
  doc = Nokogiri::XML(File.open('tmp/'+filename)) do |config|
    # NOBLANKS - Remove blank nodes
    # NOENT - Substitute entities
    # NOERROR - Suppress error reports
    # STRICT - Strict parsing; raise an error when parsing malformed documents
    # NONET - Prevent any network connections during parsing. Recommended for parsing untrusted documents.
    config.strict.nonet
  end
end


Given(/^I have "(.*?)" in data:$/) do |filename, xml|
  @filename = "tmp/"+filename
  #STDERR.puts @filename
  File.open(@filename, 'w') { |f| f.write(xml) }
end

Then(/^"(.*?)" produced in data:$/) do |filename|
  #STDERR.puts "<<<<"+Dir.pwd
  filename = "tmp/"+filename
  File.file?(filename).should == true
end

Then(/^"(.*?)" contains (\d+) wizards with stage in "(.*?)"$/) do |filename, wcount, wnames|
  doc = read_appconfig_xml(filename)
  wizards = doc.xpath('//wizard')
  wizards.count.should==wcount.to_i
  stages=[]
  wizards.each { |w| stages<<w[:stages] }
  wnames.split(',').each { |name| stages.include?(name).should==true }
end

Then(/^"(.*?)" contains (\d+) wizards with transaction in "(.*?)"$/) do |filename, wcount, wnames|
  doc = read_appconfig_xml(filename)
  wizards = doc.xpath('//wizard')
  wizards.count.should==wcount.to_i
  #wizards.each{|w|stages<<w[:stages]}
  wnames.split(',').each do |name|
    wizards.any? { |w| w[:meta].split(';')[1]==name }.should==true
  end
end

When(/^I check workers in "(.*?)"$/) do |filename|
  pending # express the regexp above with the code you wish you had
end


Then(/^"(.*?)" contains (\d+) wizards with stage order "(.*?)" and code order "(.*?)"$/) do |filename, wcount, wstages, wcodes|
  doc = read_appconfig_xml(filename)
  wizards = doc.xpath('//wizard')
  wizards.count.should==wcount.to_i
  stages=[]
  codes=[]
  wizards.each do |w| 
	  stages<<w[:stages]
	  codes<<w[:meta].split(';')[1]
  end
  stages.join(',').should==wstages
  codes.join(',').should==wcodes
end


Then(/^"(.*?)" contains (\d+) wizards with stages="(.*?)" and meta="(.*?)"$/) do |filename, wcount, wstages, wcodes|
  doc = read_appconfig_xml(filename)
  wizards = doc.xpath('//wizard')
  wizards.count.should==wcount.to_i
  #stages,codes=[]
  wizards.each do |w|  
	w[:stages].should==wstages
	w[:meta].should==wcodes
  end
end

Then(/^"(.*?)" contains (\d+) wizards with data:$/) do |filename, wcount, table|
  # table is a Cucumber::Ast::Table
  doc = read_appconfig_xml(filename)
  wizards = doc.xpath('//wizard')
  wizards.count.should==wcount.to_i
  table.hashes.each.with_index do |post,index|
	post[:meta].should==wizards[index][:meta]
	post[:stage].should==wizards[index][:stages]
  end
end