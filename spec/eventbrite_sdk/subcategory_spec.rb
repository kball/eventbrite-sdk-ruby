require 'spec_helper'

module EventbriteSDK
  RSpec.describe Subcategory do
    describe '.list' do
      it 'returns a new ResouceList' do
        stub_endpoint(
          path: 'subcategories/?page=1',
          body: :subcategories,
        )

        list = described_class.list.retrieve

        expect(list).to be_an_instance_of(ResourceList)
      end
    end

    describe 'schema' do
      it 'responds to all methods described in schema definition' do
        expect(subject).to respond_to(:name)
        expect(subject).to respond_to(:parent_category)
      end
    end

    describe '#subcategories' do
      it 'is read-only' do
        category = described_class.new(
          'name' => 'cannot change',
          'parent_category' => 'cannot change'
        )

        category.assign_attributes(
          'name' => 'is',
          'parent_category' => 'changed'
        )

        expect(category).not_to be_changed
      end
    end
  end
end
