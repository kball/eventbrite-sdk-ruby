require 'spec_helper'

module EventbriteSDK
  RSpec.describe Attendee do
    before do
      EventbriteSDK.token = 'token'
    end

    describe '.retrieve' do
      context 'when found' do
        it 'returns a new instance' do
          stub_endpoint(
            path: 'orders/123/attendees/678',
            body: :attendee_read,
          )
          attendee = described_class.retrieve order_id: '123', id: '678'

          expect(attendee).to be_an_instance_of(described_class)
        end
      end

      context 'when not found' do
        it 'throws some sort of error' do
          stub_endpoint(
            path: 'orders/10000/attendees/10000',
            status: 404,
            body: :attendee_not_found,
          )

          expect { described_class.retrieve order_id: '10000', id: '10000' }.
            to raise_error('requested object was not found')
        end
      end
    end
  end
end
