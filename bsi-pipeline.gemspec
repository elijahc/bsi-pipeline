# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bsi-pipeline/version'

Gem::Specification.new do |spec|
  spec.name          = "bsi-pipeline"
  spec.version       = Bsi::Pipeline::VERSION
  spec.authors       = ["Elijah Christensen"]
  spec.email         = ["ejd.christensen@gmail.com"]
  spec.summary       = %q{plugin for pipeline that provides importers and models for migrating data to bsi}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "terminal-notifier-guard"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "factory_girl"

  spec.add_runtime_dependency     "etl-pipeline"
  spec.add_runtime_dependency     "rbc"
end
