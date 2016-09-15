require 'spec_helper'

module EventbriteSDK
  RSpec.describe Resource::SchemaDefinition do
    subject { described_class.new('schema') }

    describe 'dynamically defined type methods: boolean datetime integer string' do
      it 'is writeable when not given read_only option' do
        %i(boolean currency datetime integer string).each do |method|
          subject.public_send(method, 'write')
          subject.public_send(method, 'read', read_only: true)

          expect(subject.writeable?('write')).to eq(true)
          expect(subject.writeable?('read')).to eq(false)
        end
      end
    end

    describe '#type' do
      context 'when key exists' do
        it "returns it's type" do
          subject.integer('key')

          expect(subject.type('key')).to eq(:integer)
        end
      end

      context 'when key does not exist' do
        it 'returns nil' do
          expect(subject.type('key')).to be_nil
        end
      end
    end

    describe '#writeable?' do
      context 'when attrs does not contain the key' do
        it 'raises an exception' do
          name = 'IMA_SPLODE_ON_U'
          key = 'not in scope'
          schema = described_class.new(name)

          expect { schema.writeable?('not in scope') }.
            to raise_error(
              EventbriteSDK::InvalidAttribute, "attribute `#{key}` not present in #{name}"
            )
        end
      end
    end
  end
end
