require 'spec_helper'

module EventbriteSDK
  RSpec.describe Report do
    describe '#event_ids' do
      context 'when given a list of event_ids' do
        it 'joins them by ","' do
          expect(subject.event_ids('1', '2', '3').query).
            to eq(event_ids: '1,2,3')
        end
      end

      context 'when given a single event_id' do
        it 'returns it as a string value' do
          expect(subject.event_ids(1).query).to eq(event_ids: '1')
        end
      end

      context 'when #event_ids is not called' do
        it 'is empty' do
          expect(subject.query).to be_empty
        end
      end
    end

    describe '#event_status' do
      context 'when given a status' do
        it 'adds event_status to #query' do
          expect(subject.event_status(:all).query).to eq(
            event_status: :all
          )
        end
      end

      context 'when #event_status is not called' do
        it 'is empty' do
          expect(subject.query).to be_empty
        end
      end
    end

    describe '#starts_date' do
      context 'when given a start_date' do
        it 'adds start_date to #query' do
          expect(subject.start_date('2010-01-31T13:00:00Z').query).
            to eq(start_date: '2010-01-31T13:00:00Z')
        end
      end

      context 'when #start_date is not called' do
        it 'returns a blank string when #query is called' do
          expect(subject.query).to be_empty
        end
      end
    end

    describe '#end_date' do
      context 'when given a end_date' do
        it 'adds end_date to #query' do
          expect(subject.end_date('2010-01-31T13:00:00Z').query).
            to eq(end_date: '2010-01-31T13:00:00Z')
        end
      end

      context 'when #end_date is not called' do
        it 'is empty' do
          expect(subject.query).to be_empty
        end
      end
    end

    describe '#timezone' do
      context 'when given a tz' do
        it 'adds event_status to #query' do
          expect(subject.timezone('America/Los_Angeles').query).
            to eq(timezone: 'America/Los_Angeles')
        end
      end

      context 'when #event_status is not called' do
        it 'is empty' do
          expect(subject.query).to be_empty
        end
      end
    end

    describe '#group_by' do
      context 'when given a grouping' do
        it 'adds group_by to #query' do
          expect(subject.group_by(:event).query).
            to eq(group_by: :event)
        end
      end

      context 'when #group_by is not called' do
        it 'returns a blank string when #query is called' do
          expect(subject.query).to be_empty
        end
      end
    end

    describe '#filter_by' do
      context 'when given a filter' do
        it 'adds filter_by to #query' do
          subject.filter_by ticket_ids: [1, 2]

          expect(subject.query).to eq(filter_by: '{"ticket_ids":[1,2]}')
        end
      end

      context 'when #filter_by is not called' do
        it 'is empty' do
          expect(subject.query).to be_empty
        end
      end
    end

    describe '#retrieve' do
      context 'when given type is valid' do
        it 'calls sdk#get with reports/:type and query' do
          sdk = double('SDK', get: true)

          result = subject.event_ids(1,2).group_by(:day).retrieve(:sales, sdk)

          expect(result).to eq(sdk.get)
          expect(sdk).to have_received(:get).with(
            url: 'reports/sales',
            query: {
              event_ids: '1,2',
              group_by: :day,
            }
          )
        end
      end

      context 'when given type is invalid' do
        it 'raises ArgumentError' do
          expect do
            subject.retrieve(type: :foo)
          end.to raise_error(
            ArgumentError,
            '`:type` is not of [:attendees, :sales]'
          )
        end
      end
    end
  end
end
