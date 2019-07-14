# # coding: utf-8
# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require 'my_gem/version'

Gem::Specification.new do |spec|
  spec.name          = "Raskell"
  spec.version       = MyGem::VERSION ## 0.1.0
  spec.authors       = ["Kian Wilcox"]
  spec.email         = ["kian+raskell@type.space"]
  spec.summary       = %q{Making Ruby a "Joy" to Work With}
  spec.description   = %q{Functional Programming With Streams in Ruby}
  spec.homepage      = "raskell.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
#mba:Git