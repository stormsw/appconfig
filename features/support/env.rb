#$DEBUG = true
require 'aruba'
require 'aruba/in_process'
require 'aruba/cucumber.rb'
require 'test/unit'
require 'appconfig'

#World(Test::Unit::Assertions)
Aruba::InProcess.main_class = Appconfig::Appconfig
Aruba.process = Aruba::InProcess