# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bukin/version'

Gem::Specification.new do |gem|
  gem.name          = 'bukin'
  gem.version       = Bukin::VERSION
  gem.authors       = ['Ryan Mendivil']
  gem.email         = ['contact@nullreff.net']
  gem.description   = 'Plugin and server package manager for Minecraft'
  gem.summary       = gem.description
  gem.homepage      = 'http://github.com/Nullreff/bukin'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.1'
  gem.add_dependency('thor', '~> 0.18.1')
  gem.add_dependency('json', '~> 1.8.0')
  gem.add_dependency('rubyzip', '~> 0.9.9')
end
