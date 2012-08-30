# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'expo_sync/version'

Gem::Specification.new do |gem|
  gem.name          = "expo_sync"
  gem.version       = ExpoSync::VERSION
  gem.authors       = ["Andrey Titar"]
  gem.email         = ["faust@dot.com.ua"]
  gem.description   = %q{Expoglobus Data Syncer}
  gem.summary       = %q{Simple object mapping}
  gem.homepage      = "http://expoglobus.com"

  gem.add_dependency('mongoid')
  gem.add_dependency('activesupport')

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
