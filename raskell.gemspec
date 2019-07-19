# # coding: utf-8
# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "raskell"
  spec.version       = Raskell::VERSION ## 0.1.0
  spec.authors       = ["Kian Wilcox"]
  spec.email         = ["kian+raskell@type.space"]
  spec.summary       = %q{Making Ruby a "Joy" to Work With}
  spec.description   = %q{Functional and Concatenative Programming With Streams in Ruby}
  spec.homepage      = "https://www.raskell.org"
  spec.metadata      = { "source_code_uri" => "https://github.com/kianwilcox/raskell" }
  
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(README.md ROADMAP.md)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_path  = "lib"
end
