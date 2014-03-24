require 'nokogiri'
require 'aruba/api'

When(/^I normalize "(.*?)"$/) do |filename|
  #aruba makes current working dir tmp/aruba...
  cmd = ''
  case platform
    when :windows
      cmd = 'appconfig.cmd normalize ../'+filename
    when :linux
      cmd = 'appconfig normalize ../'+filename
    else
      raise 'Unknown platform, barely know what to do there?!'
  end
  run_simple(unescape(cmd),false ) #need to investigate why, but windows version of childprocess raises exception
  #assert_exit_status(0)
end

When(/^I normalize with sorting "(.*?)"$/) do |filename|
  case platform
    when :windows
      cmd = "appconfig.cmd normalize ../#{filename} -s"
    when :linux
      cmd = "appconfig normalize ../#{filename} -s"
    else
      raise 'Unknown platform, barely know what to do there?!'
  end
  run_simple(unescape(cmd),false )
end
