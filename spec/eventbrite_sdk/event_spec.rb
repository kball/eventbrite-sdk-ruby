require 'spec_helper'

module EventbriteSDK
  RSpec.describe Event do
    before do
      # TODO mock once we have some real responses to store as fixtures
      EventbriteSDK.token = 'PCMBPWSLYSXBYK53IHA3'
    end

    describe '.retrieve' do
      context 'when found' do
        it 'returns a new instance' do
          event = described_class.retrieve id: '24967032065'

          expect(event).to be_an_instance_of(described_class)
        end
      end

      context 'when not found' do
        it 'throws some sort of error' do
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
      context 'when primary_key exists' do
        it 'calls save with the called method name' do
          event = described_class.new('id' => '1')
          allow(event).to receive(:save)

          event.cancel

          expect(event).to have_received(:save).with('cancel')
        end
      end

      context 'when primary_key is absent' do
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

      context 'when event exists' do
      end
    end

    describe '#publish' do
      context 'when primary_key exists' do
        it 'calls save with the called method name' do
          event = described_class.new('id' => '1')
          allow(event).to receive(:save)

          event.publish

          expect(event).to have_received(:save).with('publish')
        end
      end

      context 'when primary_key is absent' do
        it 'returns false' do
          event = described_class.new
          allow(event).to receive(:save)

          expect(event.publish).to eq(false)
        end
      end
    end

    describe '#unpublish' do
      context 'when primary_key exists' do
        it 'calls save with the called method name' do
          event = described_class.new('id' => '1')
          allow(event).to receive(:save)

          event.unpublish

          expect(event).to have_received(:save).with('unpublish')
        end
      end

      context 'when primary_key is absent' do
        it 'returns false' do
          event = described_class.new
          allow(event).to receive(:save)

          expect(event.unpublish).to eq(false)
        end
      end
    end
  end
end
