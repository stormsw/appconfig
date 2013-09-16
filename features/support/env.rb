#require 'ruby-debug'
require 'simplecov'
SimpleCov.start
#$DEBUG = true
require 'aruba'
require 'aruba/in_process'
require 'aruba/cucumber.rb'
require 'test/unit'
require 'appconfig'


#TODO remove when done
#require 'debuger'
#World(Test::Unit::Assertions)
#Aruba::InProcess.main_class = Appconfig::Appconfig
#Aruba.process = Aruba::InProcess

def platform
  if ENV['os']
    :windows
  else
    :linux #or mac :D
  end
end
