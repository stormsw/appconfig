require 'rspec'
require 'appconfig'

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

describe Appconfig::Appconfig do
  before do
    @instance = Appconfig::Appconfig.new
  end
  it 'should put "all" as last block ' do
    xml_doc  = Nokogiri::XML("<wizards><wizard stages='Stage1' assembly='WAssess'  meta='all;T1'><editor name='1'/></wizard><wizard stages='Stage1' assembly='WAssess'  meta='all;all'><editor name='1'/></wizard></wizards>")
    @instance.sort_wizards(xml_doc)
    true.should == false
  end
end