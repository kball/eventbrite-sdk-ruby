require 'spec_helper'

module EventbriteSDK
  RSpec.describe ResourceList do
    describe '#empty?' do
      it 'returns true' do
        expect(described_class.new(url_base: 'orders', object_class: Order)).
          to be_empty
      end
    end

    describe '#retrieve' do
      context 'when the request payload contains the key given' do
        it 'hydrates objects within a given key with then given object_class' do
          list = described_class.new(
            url_base: 'url',
            object_class: Event,
            key: :events
          )
          payload = {
            'events' => [
              { 'id' => '1' },
              { 'id' => '2' },
              { 'id' => '3' },
            ]
          }
          request = double('Request', get: payload)

          list.retrieve(request)

          expect(request).to have_received(:get).with(url: 'url')
          expect(list.first).to be_an_instance_of(Event)

          expect(list[0].primary_key).to eq('1')
          expect(list[1].primary_key).to eq('2')
          expect(list[2].primary_key).to eq('3')
        end
      end

      context 'when the request payload does not contain key given' do
        it 'hydrates objects within a given key with then given object_class' do
          list = described_class.new(
            url_base: 'url',
            object_class: Event,
            key: :events
          )
          payload = {
            'nope' => [
              { 'id' => '1' },
              { 'id' => '2' },
              { 'id' => '3' },
            ]
          }
          request = double('Request', get: payload)

          list.retrieve(request)

          expect(request).to have_received(:get).with(url: 'url')
          expect(list).to be_empty
        end
      end
    end

    context 'pagination' do
      it 'returns the value provided in the requests `pagination` payload' do
        list = described_class.new(
          url_base: 'url',
          object_class: Event,
          key: :events
        )

        pagination = {
          'pagination' => {
            'object_count' => 13,
            'page_number' => 2,
            'page_size' => 50,
            'page_count' => 2,
          }
        }

        list.retrieve double('Request', get: pagination)

        expect(list.object_count).to eq(13)
        expect(list.page_number).to eq(2)
        expect(list.page_size).to eq(50)
        expect(list.page_count).to eq(2)
      end
    end
  end
end
