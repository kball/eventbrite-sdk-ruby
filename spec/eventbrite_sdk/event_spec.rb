require 'spec_helper'

module EventbriteSDK
  RSpec.describe Event do
    before do
      EventbriteSDK.token = 'token'
    end

    describe '.retrieve' do
      context 'when found' do
        it 'returns a new instance' do
          stub_endpoint(
            path: 'events/1234',
            body: :event_read,
          )
          event = described_class.retrieve id: '1234'

          expect(event).to be_an_instance_of(described_class)
        end
      end

      context 'when not found' do
        it 'throws some sort of error' do
          stub_endpoint(
            path: 'events/10000',
            status: 404,
            body: :event_not_found,
          )

          expect { described_class.retrieve id: '10000' }.
            to raise_error('requested object was not found')
        end
      end
    end

    describe '.build' do
      it 'returns a hydrated instance' do
        event = described_class.build('name.html' => 'An Event')

        expect(event.name.html).to eq('An Event')
      end
    end

    describe '#cancel' do
      context 'when id exists' do
        it 'calls save with `cancel`' do
          event = described_class.new('id' => '1')
          allow(event).to receive(:save)

          event.cancel

          expect(event).to have_received(:save).with('cancel')
        end
      end

      context 'when id is absent' do
        it 'returns false' do
          event = described_class.new
          allow(event).to receive(:save)

          expect(event.cancel).to eq(false)
        end
      end
    end

    describe '#orders' do
      context 'when event is new' do
        it 'instantiates a new empty ResourceList' do
          expect(subject.orders).to be_an_instance_of(ResourceList)
          expect(subject.orders).to be_empty
        end
      end
    end

    describe '#publish' do
      context 'when id exists' do
        it 'calls save with the called method name' do
          event = described_class.new('id' => '1')
          allow(event).to receive(:save)

          event.publish

          expect(event).to have_received(:save).with('publish')
        end
      end

      context 'when id is absent' do
        it 'returns false' do
          event = described_class.new
          allow(event).to receive(:save)

          expect(event.publish).to eq(false)
        end
      end
    end

    describe '#unpublish' do
      context 'when id exists' do
        it 'calls save with the called method name' do
          event = described_class.new('id' => '1')
          allow(event).to receive(:save)

          event.unpublish

          expect(event).to have_received(:save).with('unpublish')
        end
      end

      context 'when id is absent' do
        it 'returns false' do
          event = described_class.new
          allow(event).to receive(:save)

          expect(event.unpublish).to eq(false)
        end
      end
    end
  end
end
