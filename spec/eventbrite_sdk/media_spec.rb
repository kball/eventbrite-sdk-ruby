require 'spec_helper'

module EventbriteSDK
  RSpec.describe Media do
    before do
      EventbriteSDK.token = 'token'
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

          media = described_class.new(:event_logo, File.open(file))

          expect(media.upload!).to eq(true)
          expect(media.id).to_not be_nil
          expect(media.url).to_not be_nil
        end
      end
    end
  end
end
