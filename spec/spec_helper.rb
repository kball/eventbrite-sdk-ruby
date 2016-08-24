require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'support/endpoint_stub'
require 'eventbrite_sdk'
require 'webmock/rspec'
require 'byebug'

RSpec.configure do |config|
  config.include EndpointStub
end
