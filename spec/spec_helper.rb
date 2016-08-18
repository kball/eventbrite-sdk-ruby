require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'support/endpoint_stub'
require 'eventbrite_sdk'
require 'webmock/rspec'
require 'byebug'
WebMock.allow_net_connect!
WebMock.after_request(real_requests_only: true) do |request_signature, response|
end

RSpec.configure do |config|
  config.include EndpointStub
end
