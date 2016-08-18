require 'spec_helper'

module EventbriteSDK
  RSpec.describe Resource::Schema do
    subject { described_class.new('schema') }
    describe '#writable?' do
      it 'populates @read_only when given read_only: true' do
        subject.integer 'read', read_only: true
        subject.integer 'write'

        expect(subject.writeable?('read')).to eq(false)
        expect(subject.writeable?('write')).to eq(true)
      end
    end

    describe '#integer' do
      it 'adds the given value as a key in @attrs with type as value' do
        %w(this.that that.this).each do |value|
          subject.integer value
        end

        expect(subject.type('this.that')).to eq(:integer)
        expect(subject.type('that.this')).to eq(:integer)
      end
    end

    describe '#string' do
      it 'adds the given value as a key in @attrs with type as value' do
        %w(this.that that.this).each do |value|
          subject.string value
        end

        expect(subject.type('this.that')).to eq(:string)
        expect(subject.type('that.this')).to eq(:string)
      end
    end

    describe '#boolean' do
      it 'adds the given value as a key in @attrs with type as value' do
        %w(this.that that.this).each do |value|
          subject.boolean value
        end

        expect(subject.type('this.that')).to eq(:boolean)
        expect(subject.type('that.this')).to eq(:boolean)
      end
    end

    describe '#datetime' do
      it 'adds the given value as a key in @attrs with type as value' do
        %w(this.that that.this).each do |value|
          subject.datetime value
        end

        expect(subject.type('this.that')).to eq(:datetime)
        expect(subject.type('that.this')).to eq(:datetime)
      end
    end
  end
end
