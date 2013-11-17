require 'simplecov'
SimpleCov.start

require 'aruba'
require 'aruba/in_process'
require 'aruba/cucumber.rb'
require 'test/unit'
require 'appconfig'

Aruba::InProcess.main_class = Appconfig::AppconfigRunner
Aruba.process = Aruba::InProcess

def platform
  if ENV['os']
    :windows
  else
    :linux #or mac :D
  end
end
