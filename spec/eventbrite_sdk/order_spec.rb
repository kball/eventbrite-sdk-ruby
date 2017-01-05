require 'spec_helper'

module EventbriteSDK
  RSpec.describe Order do
    before do
      EventbriteSDK.token = 'token'
    end

    describe '.retrieve' do
      context 'when found' do
        it 'returns a new instance' do
          stub_endpoint(
            path: 'orders/12345',
            body: :order_read,
          )
          order = described_class.retrieve id: '12345'

          expect(order).to be_an_instance_of(described_class)
        end
      end

      context 'when not found' do
        it 'throws some sort of error' do
          stub_endpoint(
            path: 'orders/10000',
            status: 404,
            body: :order_not_found,
          )

          expect { described_class.retrieve id: '10000' }.
            to raise_error('requested object was not found')
        end
      end
    end

    describe '.build' do
      it 'returns a hydrated instance' do
        order = described_class.build('name' => 'Emilio')

        expect(order.name).to eq('Emilio')
      end
    end

    describe '#resend_confirmation_email' do
      context 'when primary_key exists' do
        it 'calls save with `resend_confirmation_email`' do
          order = described_class.new('id' => '1')
          allow(EventbriteSDK).to receive(:post).and_return('email')

          result = order.resend_confirmation_email

          expect(result).to eq('email')
          expect(EventbriteSDK).
            to have_received(:post).
            with(url: 'orders/1/resend_confirmation_email')
        end
      end

      context 'when primary_key is absent' do
        it 'returns false' do
          order = described_class.new
          allow(order).to receive(:save)

          expect(order.resend_confirmation_email).to eq(false)
        end
      end
    end

    describe '#refund' do
      context 'when primary_key exists' do
        it 'calls save with the called method name' do
          order = described_class.new('id' => '1')
          allow(EventbriteSDK).to receive(:post).and_return('refunds')

          result = order.refund

          expect(result).to eq('refunds')
          expect(EventbriteSDK).to have_received(:post).with(
            url: 'orders/1/refunds'
          )
        end
      end

      context 'when primary_key is absent' do
        it 'returns false' do
          order = described_class.new
          allow(order).to receive(:save)

          expect(order.refund).to eq(false)
        end
      end
    end

    describe '#attendees' do
      context 'when order is new' do
        it 'instantiates a new empty ResourceList' do
          expect(subject.attendees).to be_an_instance_of(ResourceList)
          expect(subject.attendees).to be_empty
        end
      end

      context 'when order exists' do
        it 'gets attendees list' do
          stub_endpoint(
            path: 'orders/12345',
            body: :order_read,
          )
          stub_endpoint(
            path: 'orders/12345/attendees/?page=1',
            body: :attendees_read,
          )

          order = described_class.retrieve id: '12345'
          expect(order.attendees.retrieve).to be_an_instance_of(ResourceList)
          expect(order.attendees).to_not be_empty
          expect(order.attendees.count).to eq(1)
          expect(order.attendees.first).to be_an_instance_of(Attendee)
        end
      end
    end
  end
end
