require 'spec_helper'

module EventbriteSDK
  RSpec.describe Resource::Attributes do
    describe 'meta attributes' do
      it 'responds to a method if a matching key exists in @hydrated_attrs' do
        expect(subject.respond_to?(:test)).to eq(false)

        subject.assign_attributes('test' => 'now we respond to it')

        expect(subject.respond_to?(:test)).to eq(true)
      end

      it 'returns the value of the key when called' do
        subject.assign_attributes('test' => 'value')

        expect(subject.test).to eq('value')
      end

      context 'when assigning as a symbol' do
        it 'returns the value of the key when called' do
          subject.assign_attributes(test: 'value')

          expect(subject.test).to eq('value')
        end
      end

      context 'given nested attributes' do
        it 'returns a new instance of self' do
          subject.assign_attributes('nested.test' => 'value')

          expect(subject.nested).to be_an_instance_of(described_class)
          expect(subject.nested.test).to eq('value')
        end
      end
    end

    describe '#[]' do
      it 'works like a regular hash' do
        attrs = described_class.new('foo' => 'bar', baz: 'qux')

        expect(attrs['foo']).to eq('bar')
        expect(attrs[:foo]).to eq('bar')
        expect(attrs['baz']).to eq('qux')
        expect(attrs[:baz]).to eq('qux')
      end
    end

    describe '#assign_attributes' do
      it 'hydrates dot notation keys into a nested attrs' do
        subject.assign_attributes(
          'this.is.a.nested.key' => 'imavalue',
          'this.is.a.nother.key' => 'imavalue',
          'event.title' => 'imavalue'
        )

        expect(subject.attrs).to eq(
          'this' => {
            'is' => {
              'a' => {
                'nested' => {
                  'key' => 'imavalue'
                },
                'nother' => {
                  'key' => 'imavalue'
                }
              }
            }
          },
          'event' => {
            'title' => 'imavalue'
          }
        )
      end

      context 'when no schema is given' do
        it 'whitelists and assigns any attributes' do
          subject.assign_attributes('literally' => 'anything')

          expect(subject).to be_changed
        end
      end

      context 'when given schema that is writeable' do
        it 'returns a new instance' do
          schema = double('schema', writeable?: true)

          attrs = described_class.new({}, schema)
          attrs.assign_attributes('name.html' => 'An Event')

          expect(attrs).to be_changed
          expect(attrs.changes).to eq('name.html' => [nil, 'An Event'])

          attrs.assign_attributes('name.html' => 'An Event!')
          expect(attrs.changes).to eq('name.html' => ['An Event', 'An Event!'])
        end
      end

      context 'when schema is writeable for one attribute, but not another' do
        it 'returns a new instance with only writeable changes' do
          schema = double('schema', writeable?: true)
          allow(schema).to receive(:writeable?).and_return(true, false)

          attrs = described_class.new({}, schema)

          attrs.assign_attributes(
            'name.html' => 'An Event!',
            'not.changeable' => 'A value'
          )

          expect(attrs.changes).to eq('name.html' => [nil, 'An Event!'])
        end
      end

      context 'when given schema that rejects attributes' do
        it 'raises InvalidAttribute' do
          schema = Resource::SchemaDefinition.new('schema')

          attrs = described_class.new({}, schema)

          expect { attrs.assign_attributes('not.here' => 'An Event') }.
            to raise_error(
              "attribute `not.here` not present in schema"
            )
        end
      end

      context 'when given schema returns false for #writeable?' do
        it 'does not update the value in hydrated attrs' do
          schema = double('schema', writeable?: false)

          attrs = described_class.new({ 'read' => 'frozen state' }, schema)

          attrs.assign_attributes 'read' => 'new state'

          expect(attrs).not_to be_changed
          expect(attrs.read).to eq('frozen state')
        end
      end
    end

    describe '#to_json' do
      it 'calls attrs.to_h.to_json' do
        raw_attrs = { a: 'aye', b: 'bee' }

        attributes = described_class.new(raw_attrs)

        expect(attributes.to_json).to eq(raw_attrs.to_json)

      end
    end

    describe '#reset!' do
      it 'returns values to the original clean state if changed?' do
        attrs = described_class.new('this' => { 'is' => 'original' })

        attrs.assign_attributes('this.is' => 'no longer original')
        expect(attrs).to be_changed
        expect(attrs.this.is).to eq('no longer original')

        attrs.reset!

        expect(attrs).not_to be_changed
        expect(attrs.changes).to be_empty
        expect(attrs.this.is).to eq('original')
      end
    end

    describe '#payload' do
      it 'returns a hash containing the dot notation keys with changed values' do
        subject.assign_attributes('name.html' => 'An Event')

        expect(subject.payload).to eq(
          'name' => { 'html' => 'An Event' }
        )
      end

      it 'prefixes keys if a prefix is given' do
        subject.assign_attributes(
          'name.html' => 'An Event',
          'name.text' => 'An Event',
          'a.nested.struct' => 'So nested',
        )

        expect(subject.payload('prefixed')).to eq(
          'prefixed' => {
            'name' => {
              'html' => 'An Event',
              'text' => 'An Event',
            },
            'a' => {
              'nested' => {
                'struct' => 'So nested'
              }
            }
          }
        )
      end

      it 'returns an empty hash when there is no changes' do
        expect(subject.payload).to eq({})
      end
    end

    describe '#values' do
      it 'returns the values for every attribute defined' do
        attrs = described_class.new(
          'this' => 'great',
          'that' => 'ok',
          'nested' => { 'thing' => 'bad' }
        )

        expect(attrs.values).to eq(['great', 'ok', { 'thing' => 'bad' }])
      end
    end
  end
end
