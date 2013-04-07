# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gren/version'

Gem::Specification.new do |gem|
  gem.name          = "gren"
  gem.version       = Gren::VERSION
  gem.authors       = ["ongaeshi"]
  gem.email         = ["ongaeshi0621@gmail.com"]
  gem.description   = %q{gren is a next grep tool.}
  gem.summary       = %q{gren is a next grep tool. The basis is find+grep.}
  gem.homepage      = "http://gren.ongaeshi.me"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'termcolor','>= 1.2.0'
end
