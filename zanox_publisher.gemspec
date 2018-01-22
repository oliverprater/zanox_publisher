# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zanox_publisher/version'

Gem::Specification.new do |spec|
  spec.name          = 'zanox_publisher'
  spec.version       = ZanoxPublisher::VERSION
  spec.authors       = ['Oliver Prater']
  spec.email         = ['oliver.prater@gmail.com']
  spec.summary       = %q{A ruby wrapper for the ZANOX Publisher API.}
  spec.homepage      = 'http://rubygems.org/gems/zanox_publisher'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard', '~> 0.9.12'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'webmock', '~> 1.20'
  spec.add_development_dependency 'vcr', '~> 2.9'

  spec.add_dependency 'httparty', '~> 0.13'
end
