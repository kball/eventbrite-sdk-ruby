lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eventbrite_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'eventbrite_sdk'
  spec.version       = EventbriteSDK::VERSION
  spec.authors       = ['Vinnie Franco', 'Jeff McKenzie']
  spec.email         = ['vinnie@eventbrite.com', 'jeffm@eventbrite.com']

  spec.summary       = %{Write a short summary, because Rubygems requires one.}
  spec.description   = %{Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/eventbrite"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rest-client'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
end
