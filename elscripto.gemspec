# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "elscripto/version"

Gem::Specification.new do |s|
  s.name        = "elscripto"
  s.version     = Elscripto::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Achilles Charmpilas"]
  s.email       = ["ac@humbuckercode.co.uk"]
  s.homepage    = "http://github.com/Achillefs/elscripto"
  s.summary     = %q{Console window group automation for developers}
  s.description = %q{Console window group automation for developers}
  spec.license  = 'MIT'

  s.rubyforge_project = "elscripto"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency('nutrun-string')
  s.add_development_dependency('rspec')
end
