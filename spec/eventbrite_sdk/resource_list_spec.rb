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
      context 'when @expansion is set' do
        it 'calls request with an expansion query' do
          request = double('Request', get: {})

          list = described_class.new(request: request)

          list.with_expansion('organizer', :event, 'event.venue').retrieve

          expect(request).to have_received(:get).with(
            url: nil,
            query: { page: 1, expand: 'organizer,event,event.venue' }
          )
        end

        context 'when another page is requested' do
          it 'continues to paginate with the original expansion' do
            payload = {
              'pagination' => { 'page_number' => 1, 'page_count' => 2 }
            }
            request = double('Request', get: payload)

            list = described_class.new(request: request)

            list.with_expansion('organizer', :event, 'event.venue').retrieve

            list.next_page

            expect(request).to have_received(:get).with(
              url: nil,
              query: { page: 2, expand: 'organizer,event,event.venue' }
            )
          end
        end
      end

      context 'when the request payload contains the key given' do
        it 'hydrates objects within a given key with then given object_class' do
          payload = {
            'events' => [
              { 'id' => '1' },
              { 'id' => '2' },
              { 'id' => '3' },
            ]
          }

          request = double('Request', get: payload)

          list = described_class.new(
            url_base: 'url',
            object_class: Event,
            key: :events,
            request: request,
          )

          list.retrieve

          expect(request).to have_received(:get).with(
            url: 'url', query: { page: 1 }
          )
          expect(list.first).to be_an_instance_of(Event)

          expect(list[0].id).to eq('1')
          expect(list[1].id).to eq('2')
          expect(list[2].id).to eq('3')
        end
      end

      context 'when the request payload does not contain key given' do
        it 'hydrates objects within a given key with given object_class' do
          payload = {
            'nope' => [
              { 'id' => '1' },
              { 'id' => '2' },
              { 'id' => '3' },
            ]
          }

          request = double('Request', get: payload)

          list = described_class.new(
            url_base: 'url',
            object_class: Event,
            key: :events,
            request: request,
          )

          list.retrieve

          expect(request).to have_received(:get).with(
            url: 'url', query: { page: 1 }
          )
          expect(list).to be_empty
        end
      end
    end

    context 'pagination' do
      it 'returns the value provided in the requests `pagination` payload' do
        pagination = {
          'pagination' => {
            'object_count' => 13,
            'page_number' => 2,
            'page_size' => 50,
            'page_count' => 2,
          }
        }

        request = double('Request', get: pagination)

        list = described_class.new(
          url_base: 'url',
          object_class: Event,
          key: :events,
          request: request,
        )

        list.retrieve

        expect(list.object_count).to eq(13)
        expect(list.page_number).to eq(2)
        expect(list.page_size).to eq(50)
        expect(list.page_count).to eq(2)
      end

      it 'retrieves page number when calling #page' do
        payload = {
          'events' => [
            { 'id' => '1' },
            { 'id' => '2' },
            { 'id' => '3' },
          ]
        }

        request = double('Request', get: payload)

        list = described_class.new(
          url_base: 'url',
          object_class: Event,
          key: :events,
          request: request,
        )

        allow(list).to receive(:page=)

        list.page(2)

        expect(request).to have_received(:get).with(
          url: 'url', query: { page: 2 }
        )
      end

      it 'retrieves next page when calling #next_page' do
        page_number = 1
        pagination = {
          'pagination' => {
            'object_count' => 130,
            'page_number' => page_number,
            'page_size' => 50,
            'page_count' => 2,
          }
        }

        request = double('Request', get: pagination.dup)

        list = described_class.new(
          url_base: 'url',
          object_class: Event,
          key: :events,
          request: request,
        )

        list.retrieve
        list.next_page

        expect(request).to have_received(:get).with(
          url: 'url',
          query: { page: page_number }
        )
        expect(request).to have_received(:get).with(
          url: 'url',
          query: { page: page_number + 1 }
        )
      end

      it 'retrieves previous page when calling #prev_page' do
        page_number = 2
        pagination = {
          'pagination' => {
            'object_count' => 130,
            'page_number' => page_number,
            'page_size' => 50,
            'page_count' => 2,
          }
        }

        request = double('Request', get: pagination.dup)

        list = described_class.new(
          url_base: 'url',
          object_class: Event,
          key: :events,
          request: request,
        )

        list.page(2)
        list.prev_page

        expect(request).to have_received(:get).with(
          url: 'url',
          query: { page: page_number }
        )
        expect(request).to have_received(:get).with(
          url: 'url',
          query: { page: page_number - 1 }
        )
      end
    end

    describe '#to_json' do
      it 'returns a JSON list of objects' do
        payload = {
          'events' => [
            { 'id' => '1' },
            { 'id' => '2' },
            { 'id' => '3' },
          ],
          'pagination' => {
            'object_count' => 3,
            'page_number' => 1,
            'page_size' => 50,
            'page_count' => 1,
          }
        }

        request = double('Request', get: payload)

        list = described_class.new(
          url_base: 'url',
          object_class: Event,
          key: :events,
          request: request,
        )

        list.retrieve

        list_json = JSON.parse(list.to_json)
        payload_json = JSON.parse(payload.to_json)

        expect(list_json).to eq(payload_json)
      end
    end
  end
end
