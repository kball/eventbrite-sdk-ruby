require 'spec_helper'

module EventbriteSDK
  class Resource
    module Operations
      RSpec.describe Endpoint do
        describe '.retrieve' do
          it 'subs any matching keys with the given values and instantiates a new instance with returned payload' do
            payload = 'payload'
            request = double('Request', get: payload)

            result = TestEndpoint.retrieve({ 'id' => 1 }, request)

            expect(request).to have_received(:get).with(url: 'test/1', query: nil)
            expect(result.payload).to eq(payload)
          end

          it 'when given an :expand option it passes as full options' do
            payload = 'payload'
            request = double('Request', get: payload)

            result = TestEndpoint.retrieve({ id: 1 , expand: 'events' }, request)

            expect(request).
              to have_received(:get).
              with(url: 'test/1', query: { expand: 'events' })
            expect(result.payload).to eq(payload)

          end
        end

        describe '.resource_path' do
          it 'sets singletone instance vars' do
            test_class = Class.new { include Endpoint }
            test_class.resource_path 'path'

            expect(test_class.path).to eq('path')
          end

          it 'sets attr_accessor on each token in given path' do
            test_class = Class.new do
              include Endpoint
              resource_path '/:one/:two/:three'
            end

            instance = test_class.new

            expect(instance.respond_to?(:one)).to eq(true)
            expect(instance.respond_to?(:two)).to eq(true)
            expect(instance.respond_to?(:three)).to eq(true)
          end
        end

        describe '#path' do
          context 'when given a resource without surrogate keys' do
            it 'returns a path with the values injected' do
              endpoint = TestEndpoint.new('nothing')

              expect(endpoint.path).to eq('test/id')
            end
          end

          context 'when given a resource with surrogate keys' do
            it 'returns a path with the values injected' do
              endpoint = TestNestedEndpoint.new('nothing')

              expect(endpoint.path).to eq('nested/nested/test/id')
            end
          end

          context 'when given an optional postfixed_path' do
            it 'postfixes the path with the given string' do
              endpoint = TestEndpoint.new('nothing')

              expect(endpoint.path('post')).to eq('test/id/post')
            end
          end

          context 'when not given an optional postfixed_path' do
            it 'postfixes the path with the given string' do
              endpoint = TestEndpoint.new('nothing')

              expect(endpoint.path).to eq('test/id')
            end
          end
        end

        describe '#full_url' do
          it 'returns the value of request#url' do
            request = double('Request', url: 'return')

            endpoint = TestEndpoint.new('nothing')

            expect(endpoint.full_url(request)).to eq(request.url)
            expect(request).to have_received(:url).with endpoint.path
          end
        end

        private

        class TestEndpoint
          include Endpoint

          attr_reader :payload

          resource_path 'test/:id'

          def initialize(payload)
            @payload = payload
          end

          def id
            'id'
          end
        end

        class TestNestedEndpoint
          include Endpoint

          attr_reader :payload

          resource_path 'nested/:nested/test/:id'

          def initialize(payload)
            @payload = payload
          end

          def id
            'id'
          end

          def nested
            'nested'
          end
        end
      end
    end
  end
end
