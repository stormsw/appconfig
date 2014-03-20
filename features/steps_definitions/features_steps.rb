require 'nokogiri'
require 'aruba/api'
#require 'aruba/cucumber/hooks'
#require 'aruba/reporting'
#World(Aruba::Api)

Given(/^I have "(.*?)" in data:$/) do |filename, xml|
  @filename = "tmp/"+filename
  #STDERR.puts @filename
  File.open(@filename, 'w') { |f| f.write(xml) }
end

When(/^I normalize "(.*?)"$/) do |filename|
  #aruba makes current working dir tmp/aruba...
  case platform
    when :windows
      cmd = 'appconfig.cmd normalize ../'+filename
    when :linux
      cmd = 'appconfig normalize ../'+filename
    else
      raise "Unknown platform, barely know what to do there?!"
  end
  run_simple(unescape(cmd),false ) #need to investigate why, but windows version of childprocess raises exception
  #assert_exit_status(0)
end

Then(/^"(.*?)" produced in data:$/) do |filename|
  #STDERR.puts "<<<<"+Dir.pwd
  filename = "tmp/"+filename
  File.file?(filename).should == true
end

Then(/^"(.*?)" contains (\d+) wizards with stage in "(.*?)"$/) do |filename, wcount, wnames|
  doc = Nokogiri::XML(File.open('tmp/'+filename)) do |config|
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

When(/^I optimize "(.*?)"$/) do |filename|
  #aruba makes current working dir tmp/aruba...
  case platform
    when :windows
      cmd = 'appconfig.cmd optimize ../'+filename
    when :linux
      cmd = 'appconfig optimize ../'+filename
    else
      raise "Unknown platform, barely know what to do there?!"
  end
  run_simple(unescape(cmd),false) #windows version fails 
  #assert_exit_status(0)
end

When(/^I check workers in "(.*?)"$/) do |filename|
  pending # express the regexp above with the code you wish you had
end

When(/^I normalize with sorting "(.*?)"$/) do |filename|
  case platform
    when :windows
      cmd = "appconfig.cmd normalize ../#{filename} -s"
    when :linux
      cmd = "appconfig normalize ../#{filename} -s"
    else
      raise "Unknown platform, barely know what to do there?!"
  end
  run_simple(unescape(cmd),false )
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