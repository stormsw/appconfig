# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'appconfig/version'

Gem::Specification.new do |spec|
  spec.name = "appconfig"
  spec.version = Appconfig::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Alexander Varchenko"]
  spec.email = ['ovarchenko@ils.com.ua']
  spec.description = %q{Tool to help you with LRS Indexer configuration aka app.config}
  spec.summary = %q{There provided validation and optimization basic functionality}
  spec.homepage = "http://gitnisga.ua.landsystems.com/ovarchenko/appconfig"
  spec.license = "MIT"

  spec.files = Dir['bin/*'] +Dir['lib/**/*'] + ['README.md', 'MIT-LICENSE'] #`git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'nokogiri'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
                                                                            #gem 'rack'
  spec.add_development_dependency 'rspec' #, :require => 'spec'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'aruba', "~> 0.5.3"
end
