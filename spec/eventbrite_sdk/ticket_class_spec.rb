require 'spec_helper'

module EventbriteSDK
  RSpec.describe TicketClass do
    describe 'defined schema' do
      it 'responds to all everything defined in the schema' do
        expect(subject).to respond_to :name
        expect(subject).to respond_to :description
        expect(subject).to respond_to :quantity_total
        expect(subject).to respond_to :cost
        expect(subject).to respond_to :fee
        expect(subject).to respond_to :tax
        expect(subject).to respond_to :free
        expect(subject).to respond_to :include_fee
        expect(subject).to respond_to :split_fee
        expect(subject).to respond_to :sales_channels
        expect(subject).to respond_to :sales_start
        expect(subject).to respond_to :sales_end
        expect(subject).to respond_to :sales_start_after
        expect(subject).to respond_to :minimum_quantity
        expect(subject).to respond_to :maximum_quantity
        expect(subject).to respond_to :auto_hide
        expect(subject).to respond_to :hidden
        expect(subject).to respond_to :order_confirmation_message
        expect(subject).to respond_to :on_sale_status
      end
    end

    describe '.retrieve' do
      context 'when found' do
        it 'returns the new instance with the populated attributes' do
          stub_endpoint(
            path: 'events/1234/ticket_classes/900',
            body: :ticket_read,
          )
          ticket = described_class.retrieve event_id: 1234, id: 900

          expect(ticket).to be_an_instance_of(described_class)
          expect(ticket.id).to eq('55031113')
          expect(ticket.event_id).to eq('27943907981')
          expect(ticket.quantity_total).to eq(100)
        end
      end

      context 'when not found' do
        it 'throws a NOT FOUND error' do
          stub_endpoint(
            path: 'events/1/ticket_classes/2',
            status: 404,
            body: :ticket_not_found,
          )

          expect { described_class.retrieve event_id: 1, id: 2 }.
            to raise_error('requested object was not found')
        end
      end
    end

    describe '.build' do
      it 'returns a hydrated instance' do
        ticket = described_class.build('name' => 'A Ticket')

        expect(ticket.name).to eq('A Ticket')
      end
    end

    describe '#available?' do
      context 'when resource responds to :on_sale_status' do
        context 'and #on_sale_status returns ON_SALE_STATUS_AVAILABLE' do
          it 'returns true' do
            ticket = described_class.new(
              # This is read only - so we have to specify by using #new
              'on_sale_status' => described_class::ON_SALE_STATUS_AVAILABLE
            )

            expect(ticket).to be_available
          end
        end

        context 'and #on_sale_status returns anything other than ON_SALE_STATUS_AVAILABLE' do
          it 'returns false' do
            # This is read only - so we have to specify by using #new
            ticket = described_class.new('on_sale_status' => 'foo')

            expect(ticket).not_to be_available
          end
        end
      end

      context 'when resource does not respond to :on_sale_status' do
        it 'returns false' do
          expect(subject).not_to be_available
        end
      end
    end

    describe '#available_in_the_future?' do
      context 'when resource responds to :on_sale_status' do
        context 'and #on_sale_status returns NOT_YET_ON_SALE' do
          it 'returns true' do
            ticket = described_class.new(
              # This is read only - so we have to specify by using #new
              'on_sale_status' => described_class::NOT_YET_ON_SALE
            )

            expect(ticket).to be_available_in_the_future
          end
        end

        context 'and #on_sale_status returns anything other than NOT_YET_ON_SALE' do
          it 'returns false' do
            # This is read only - so we have to specify by using #new
            ticket = described_class.new('on_sale_status' => 'foo')

            expect(ticket).not_to be_available_in_the_future
          end
        end
      end

      context 'when resource does not respond to :on_sale_status' do
        it 'returns false' do
          expect(subject).not_to be_available_in_the_future
        end
      end
    end

    describe '#hide!' do
      context 'when #hidden returns false' do
        it 'calls #assign_attributes with "hidden" => true and #save' do
          ticket = described_class.build('hidden' => false)

          allow(ticket).to receive(:assign_attributes)
          allow(ticket).to receive(:save).and_return(:saved)

          expect(ticket.hide!).to eq(:saved)
          expect(ticket).to have_received(:assign_attributes).
            with('hidden' => true)
        end
      end

      context 'when #hidden returns true' do
        it 'returns true' do
          ticket = described_class.build('hidden' => true)

          allow(ticket).to receive_message_chain(:assign_attributes, :save).
            and_raise('I should not have been called!')

          expect(ticket.hide!).to eq(true)
        end
      end
    end

    describe '#unhide!' do
      context 'when #hidden returns true' do
        it 'calls #assign_attributes with "hidden" => false and #save' do
          ticket = described_class.build('hidden' => true)

          allow(ticket).to receive(:assign_attributes)
          allow(ticket).to receive(:save).and_return(:saved)

          expect(ticket.unhide!).to eq(:saved)
          expect(ticket).to have_received(:assign_attributes).
            with('hidden' => false)
        end
      end

      context 'when #hidden returns false' do
        it 'returns true' do
          ticket = described_class.build('hidden' => false)

          allow(ticket).to receive_message_chain(:assign_attributes, :save).
            and_raise('I should not have been called!')

          expect(ticket.unhide!).to eq(true)
        end
      end
    end
  end
end
