# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jober/version'

Gem::Specification.new do |spec|
  spec.name          = "jober"
  spec.version       = Jober::VERSION
  spec.authors       = ["'Konstantin Makarchev'"]
  spec.email         = ["'kostya27@gmail.com'"]
  spec.summary       = %q{Simple background jobs, queues.}
  spec.description   = %q{Simple background jobs, queues.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'redis'

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activerecord", '~> 3.2'
  spec.add_development_dependency "sqlite3-ruby"
  spec.add_development_dependency "i18n", '~> 0.6.0'
end
