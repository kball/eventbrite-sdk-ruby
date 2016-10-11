require 'spec_helper'

module EventbriteSDK
  RSpec.describe Media do
    before do
      EventbriteSDK.token = 'token'
    end

    describe '.retrieve' do
      context 'when found' do
        it 'returns a new instance' do
          stub_endpoint(
            path: 'media/1234',
            body: :media_read,
          )
          media = described_class.retrieve id: '1234'

          expect(media).to be_an_instance_of(described_class)
        end
      end

      context 'when not found' do
        it 'throws some sort of error' do
          stub_endpoint(
            path: 'media/10000',
            status: 404,
            body: :media_not_found,
          )

          expect { described_class.retrieve id: '10000' }.
            to raise_error('requested object was not found')
        end
      end
    end

    describe '#upload' do
      context 'when uploading an event logo' do
        it 'should upload it and hydrate attributes' do
          stub_get(
            path: 'media/upload/?type=image-event-logo',
            fixture: :media_upload_instructions
          )

          stub_request(:post, 'https://s3.amazonaws.com/uploader/')

          stub_post_with_response(
            path: 'media/upload', fixture: :media_upload_notify
          )

          file = File.join(
            File.dirname(__FILE__), '../fixtures', 'eb-logo.jpg'
          )

          media = described_class.new
          result = media.upload! :event_logo, File.open(file)

          expect(result).to eq(true)
          expect(media.id).to_not be_nil
          expect(media.url).to_not be_nil
        end

        context 'and invalid image type is given' do
          it 'should return argument error' do
            media = described_class.new

            expect do
              media.upload! '', nil
            end.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
