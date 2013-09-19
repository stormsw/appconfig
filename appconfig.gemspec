# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'appconfig/version'

Gem::Specification.new do |spec|
  spec.name = "lrs-appconfig"
  spec.version = Appconfig::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Alexander Varchenko"]
  spec.email = ['ovarchenko@ils.com.ua']
  spec.description = %q{Tool to help you with LRS Indexer configuration aka app.config}
  spec.summary = %q{There provided validation and optimization basic functionality}
  spec.homepage = "http://gitnisga/appconfig"
  spec.license = "MIT"

  spec.files = Dir['bin/*'] +Dir['lib/**/*'] + ['README.md', 'MIT-LICENSE'] #`git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor', '~> 0.18'
  spec.add_dependency 'nokogiri', '~>1.6'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~>10.1'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'cucumber', '~> 1.3'
  spec.add_development_dependency 'aruba', '~> 0.5.3'
  spec.add_development_dependency 'simplecov', '~> 0.7.1'
end
