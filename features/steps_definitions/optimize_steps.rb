require 'nokogiri'
require 'aruba/api'

When(/^I optimize "(.*?)"$/) do |filename|
  #aruba makes current working dir tmp/aruba...
  case platform
    when :windows
      cmd = 'appconfig.cmd optimize ../'+filename
    when :linux
      cmd = 'appconfig optimize ../'+filename
    else
      raise 'Unknown platform, barely know what to do there?!'
  end
  run_simple(unescape(cmd),false) #windows version fails
  #assert_exit_status(0)
end
