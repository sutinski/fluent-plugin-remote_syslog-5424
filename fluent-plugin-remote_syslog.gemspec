# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-remote_syslog-5424"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["Sergei Utinski"]
  spec.email         = ["sergei.utinski@hpe.com"]
  spec.summary       = %q{Fluentd output plugin for remote syslog using RFC 5424}
  spec.description   = spec.description
  spec.homepage      = "https://github.com/hpcloud/fluent-plugin-remote_syslog-5424"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit-minitest"
  spec.add_development_dependency "minitest"

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "fluent-mixin-plaintextformatter"
  spec.add_runtime_dependency "fluent-mixin-config-placeholders"
  spec.add_runtime_dependency "fluent-mixin-rewrite-tag-name"
end
