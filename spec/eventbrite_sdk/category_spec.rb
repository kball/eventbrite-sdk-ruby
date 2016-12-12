require 'spec_helper'

module EventbriteSDK
  RSpec.describe Category do
    describe '.list' do
      it 'returns a new ResouceList' do
        stub_endpoint(
          path: 'categories/?page=1',
          body: :categories,
        )

        list = described_class.list.retrieve

        expect(list).to be_an_instance_of(ResourceList)
      end
    end

    describe 'schema' do
      it 'responds to all methods described in schema definition' do
        expect(subject).to respond_to(:name)
        expect(subject).to respond_to(:name_localized)
        expect(subject).to respond_to(:short_name)
        expect(subject).to respond_to(:subcategories)
      end
    end

    describe '#subcategories' do
      it 'is read-only' do
        category = described_class.new 'subcategories' => 'cannot change'

        category.assign_attributes(
          'name' => 'hey',
          'name_localized' => 'can',
          'short_name' => 'you',
          'subcategories' => 'change?'
        )

        expect(category).not_to be_changed
      end
    end
  end
end
