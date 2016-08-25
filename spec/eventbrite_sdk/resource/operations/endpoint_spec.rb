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

            expect(request).to have_received(:get).with(url: 'test/1')
            expect(result.payload).to eq(payload)
          end
        end

        describe '.resource_path' do
          it 'sets instance vars' do
            test_class = Class.new { include Endpoint }
            test_class.resource_path 'path', 'path_opts'

            expect(test_class.path).to eq('path')
            expect(test_class.path_opts).to eq('path_opts')
          end
        end

        describe '.generate_path' do
          it 'subs out the primary_key with given value' do
            expect(TestEndpoint.generate_path('id')).to eq('test/id')
          end
        end

        describe '#path' do
          context 'when given an optional postfixed_path' do
            it 'postfixes the path with the given string' do
              endpoint = TestEndpoint.new('nothing')

              expect(endpoint.path('post')).to eq('test/primary_key/post')
            end
          end

          context 'when not given an optional postfixed_path' do
            it 'postfixes the path with the given string' do
              endpoint = TestEndpoint.new('nothing')

              expect(endpoint.path).to eq('test/primary_key')
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

          resource_path 'test/:id', primary_key: :id

          def initialize(payload)
            @payload = payload
          end

          def primary_key
            'primary_key'
          end
        end
      end
    end
  end
end
