# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gren/version'

Gem::Specification.new do |gem|
  gem.name          = "gren"
  gem.version       = Gren::VERSION
  gem.authors       = ["ongaeshi"]
  gem.email         = ["ongaeshi0621@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'termcolor','>= 1.2.0'
  gem.add_dependency 'rroonga','>= 1.0.0'
  gem.add_dependency 'rack','>=1.2.1'
  gem.add_dependency 'launchy', '>=0.3.7'
end
