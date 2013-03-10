# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bukin/version'

Gem::Specification.new do |gem|
  gem.name          = "bukin"
  gem.version       = Bukin::VERSION
  gem.authors       = ["Ryan Mendivil"]
  gem.email         = ["rsmendivil@gmail.com"]
  gem.description   = %q{Plugin and server package manager for bukkit}
  gem.summary       = %q{Plugin and server package manager for bukkit}
  gem.homepage      = "http://github.com/Nullreff/bukin"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
