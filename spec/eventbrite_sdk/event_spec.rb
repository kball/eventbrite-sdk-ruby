require 'spec_helper'

module EventbriteSDK
  RSpec.describe Event do
    before do
      # TODO mock once we have some real responses to store as fixtures
      EventbriteSDK.token = 'PCMBPWSLYSXBYK53IHA3'
    end

    describe '.find' do
      context 'when found' do
        it 'returns a new instance' do
          event = described_class.find id: '24967032065'

          expect(event).to be_an_instance_of(described_class)
        end
      end

      context 'when not found' do
        it 'throws some sort of error' do
          expect { described_class.find id: '10000' }.
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
  end
end
