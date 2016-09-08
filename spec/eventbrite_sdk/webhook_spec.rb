require 'spec_helper'

module EventbriteSDK
  RSpec.describe Webhook do
    before { EventbriteSDK.token = 'token' }

    describe '.retrieve' do
      context 'when found' do
        it 'returns a new instance' do
          stub_endpoint(
            path: 'webhooks/1234',
            body: :webhook_retrieve,
          )
          event = described_class.retrieve id: '1234'

          expect(event).to be_an_instance_of(described_class)
        end
      end

      context 'when not found' do
        it 'throws an error' do
          stub_endpoint(
            path: 'webhooks/10000',
            status: 404,
            body: :webhook_not_found,
          )

          expect { described_class.retrieve id: '10000' }.
            to raise_error('requested object was not found')
        end
      end
    end

    describe '.build' do
      it 'returns a populated instance' do
        event = described_class.build(
          'actions' => 'foo',
          'endpoint_url' => 'http://some.url',
          'event_id' => '100',
        )

        expect(event.actions).to eq('foo')
        expect(event.event_id).to eq('100')
        expect(event.endpoint_url).to eq('http://some.url')
      end
    end
  end
end
