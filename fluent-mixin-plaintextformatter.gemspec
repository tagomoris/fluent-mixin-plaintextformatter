# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-mixin-plaintextformatter"
  gem.version       = "0.2.2"
  gem.authors       = ["TAGOMORI Satoshi"]
  gem.email         = ["tagomoris@gmail.com"]
  gem.description   = %q{included to format values into json, tsv or csv}
  gem.summary       = %q{Text formatter mixin module to create fluentd plugin}
  gem.homepage      = "https://github.com/tagomoris/fluent-mixin-plaintextformatter"
  gem.license       = "APLv2"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "ltsv"
end
