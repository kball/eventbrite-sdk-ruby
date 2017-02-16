require 'spec_helper'

module EventbriteSDK
  class Resource
    module Operations
      RSpec.describe Relationships do
        describe '.belongs_to' do
          it 'defines a method that calls .retrieve on a matching class' do
            wheel = TestRelations::Wheel.new

            expect(wheel.car).to eq(id: 'car_id')
          end
        end

        describe '.has_many' do
          context 'when resource#new? is true' do
            it 'returns a BlankResourceList' do
              car = TestRelations::Car.new
              allow(car).to receive(:new?).and_return(true)

              result = car.wheels

              expect(result).to be_an_instance_of(BlankResourceList)
            end
          end

          context 'when resource#new? is false' do
            it 'defines a method that returns a new list_class instance' do
              allow(ResourceList).to receive(:new).and_call_original
              car = TestRelations::Car.new

              result = car.wheels

              expect(result).to be_an_instance_of(ResourceList)

              expect(ResourceList).to have_received(:new).with(
                url_base:
                  car.path(:wheels),
                object_class:
                  EventbriteSDK::Resource::Operations::TestRelations::Wheel,
                key:
                  'wheels'
              )
            end
          end
        end

        private

        module TestRelations

          class Car
            include Relationships

            has_many :wheels, object_class: 'Wheel', key: 'wheels'

            def self.retrieve(value)
              value # Just pass through given value
            end

            def new?
              false
            end

            def path(arg)
              arg
            end

            def resource_class_from_string(string)
              TestRelations.const_get(string)
            end
          end

          class Wheel
            include Relationships

            belongs_to :car, object_class: 'Car'

            def car_id
              'car_id'
            end

            def resource_class_from_string(string)
              TestRelations.const_get(string)
            end
          end
        end
      end
    end
  end
end
