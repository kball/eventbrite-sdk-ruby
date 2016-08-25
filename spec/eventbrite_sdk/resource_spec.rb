require 'spec_helper'

module EventbriteSDK
  RSpec.describe Resource do
    describe '#id' do
      it 'returns value when hydrated attributes contains id' do
        described_class.resource_path 'events/:id', primary_key: :id

        resource = described_class.new('id' => '1234')

        expect(resource.primary_key).to eq('1234')
      end

      it 'returns nil when hydrated attributes does not contain id' do
        described_class.resource_path 'events/:venue_id', primary_key: :venue_id

        resource = described_class.new('something' => '1234')

        expect(resource.primary_key).to be_nil
      end
    end

    describe '#new?' do
      it 'returns true when primary_key is falsey' do
        described_class.resource_path 'events/:venue_id', primary_key: :venue_id

        resource = described_class.new('something' => '1234')

        expect(resource).to be_new
      end

      it 'returns false when primary_key is truthy' do
        described_class.resource_path 'events/:venue_id', primary_key: :venue_id

        resource = described_class.new('venue_id' => '1234')

        expect(resource).not_to be_new
      end
    end

    describe '#refresh!' do
      before do
        EventbriteSDK.token = 'token'
      end

      context 'when a primary_key exists' do
        it 'reloads the instance from the return of the api' do
          stub_get(path: 'events/1', fixture: :event_read)

          event = DummyResource.new('id' => '1')

          event.assign_attributes 'name.html' => 'Foo'
          expect(event.name.html).to eq('Foo')

          event.refresh!

          expect(event.name.html).to eq('This is a test name')
        end
      end

      context 'when primary_key is nil' do
        it 'returns false'  do
          described_class.resource_path 'events/:id', primary_key: :id

          resource = described_class.new('anything' => '1234')

          expect(resource.refresh!).to eq(false)
        end
      end

      private

      class DummyResource < Resource
        resource_path 'events/:id', primary_key: :id

        attributes_prefix 'event'

        schema_definition do
          string 'name.html'
        end
      end
    end

    describe '#save' do
      before do
        EventbriteSDK.token = 'token'
      end

      context 'with a new resource' do
        context 'when save is successful' do
          it 'sets the returned id, and resets changes' do
            name = "Test event #{SecureRandom.hex(4)}"

            described_class.resource_path 'events/:id', primary_key: :id
            described_class.attributes_prefix 'event'
            allow(described_class).to receive(:schema).and_return(
              Resource::NullSchemaDefinition.new
            )

            stub_post_with_response(
              path: 'events',
              fixture: :event_created,
              override: {
                'id' => 'new',
                'name' => {
                  'html' => name,
                }
              }
            )

            resource = described_class.build(
              'name.html' => name,
              'start.timezone' => 'America/Los_Angeles',
              'start.utc' => '2016-06-06T02:00:00Z',
              'end.timezone' => 'America/Los_Angeles',
              'end.utc' => '2016-07-06T02:00:00Z',
              'currency' => 'USD',
            )

            expect(resource.save).to eq(true)

            expect(resource.primary_key).not_to be_nil
            expect(resource.name.html).to eq(name)
            expect(resource).not_to be_new
            expect(resource).not_to be_changed
          end
        end
      end

      context 'when a resource that has a primary_key' do
        it 'rehydrates the instance with the response of the endpoint' do
          name = "Test event #{SecureRandom.hex(4)}"
          stub_get(
            path: 'events/111',
            fixture: :event_read,
            override: { 'id' => '111' },
          )
          stub_post_with_response(
            path: 'events/111',
            fixture: :event_created,
            override: {
              'name' => {
                'html' => name,
                'text' => name
              }
            }
          )
          event = DummyResource.retrieve(id: '111')

          event.assign_attributes('name.html' => name)

          event.save

          expect(event.name.html).to eq(name)
        end
      end

      context 'when given a postfix_path' do
        it 'passes it to endpoint_path' do
          described_class.resource_path 'events/:id', primary_key: :id
          resource = described_class.new('id' => '1234')
          repo = double(post: { 'id' => '1234' })

          resource.save('postfix', repo)

          expect(repo).to have_received(:post).with(
            url: 'events/1234/postfix', payload: {}
          )
        end
      end
    end
  end
end
