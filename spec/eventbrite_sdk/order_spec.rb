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
            path: 'orders/1234',
            body: :order_read,
          )
          order = described_class.retrieve id: '1234'

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
          allow(order).to receive(:save)

          order.resend_confirmation_email

          expect(order).to have_received(:save).
            with('resend_confirmation_email')
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
          allow(order).to receive(:save)

          order.refund

          expect(order).to have_received(:save).with('refunds')
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
  end
end
