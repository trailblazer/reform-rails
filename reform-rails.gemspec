# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reform/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "reform-rails"
  spec.version       = Reform::Rails::VERSION
  spec.authors       = ["Nick Sutterer"]
  spec.email         = ["apotonick@gmail.com"]

  spec.summary       = %q{Automatically load and include all common Rails form features.}
  spec.description   = %q{Automatically load and include all common Reform features for a standard Rails environment.}
  spec.homepage      = "https://github.com/trailblazer/reform-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
                         f.match(%r{^(test/|spec/|features/|database.sqlite3)})
                       end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "reform", ">= 2.3.1", "< 3.0.0"
  spec.add_dependency "activemodel", ">= 5.0"
end
