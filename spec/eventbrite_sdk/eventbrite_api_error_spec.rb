require 'spec_helper'

module EventbriteSDK
  RSpec.describe EventbriteAPIError do
    describe '#parsed_error' do
      context 'when response responds to :body' do
        it 'returns the body as parsed JSON' do
          resp = double(body: '{ "foo": "oof" }')

          parsed_error = described_class.new('message', resp).parsed_error

          expect(parsed_error).to eq('foo' => 'oof')
        end
      end

      context 'when response does not respond to :body' do
        it 'returns an error object with the message' do
          parsed_error = described_class.new('hi').parsed_error

          expect(parsed_error['error_description']).to eq('hi')
        end
      end
    end

    describe '#status_code' do
      context 'when response responds to :code' do
        it 'returns the code' do
          resp = double(code: 123)

          status_code = described_class.new('message', resp).status_code

          expect(status_code).to eq(resp.code)
        end
      end

      context 'when response does not respond to :code' do
        it 'returns :none' do
          status_code = described_class.new.status_code

          expect(status_code).to eq(:none)
        end
      end
    end
  end
end
