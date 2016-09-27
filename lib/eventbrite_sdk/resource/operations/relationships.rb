module EventbriteSDK
  class Resource
    module Operations
      # Adds +belongs_to+ and +has_many+
      # relationship functionality to Resource instances
      #
      # Requires that included class responds_to:
      # :resource_path
      #   returns a path that will be given to the list_class on instantiation
      #   must have an arity of 1
      # :resource_class_from_string
      #   Should constantize the string into the
      #   class of the operating relationship
      # :list_class
      #   Should return the class responsible for handling many of a resource
      module Relationships
        module ClassMethods
          # Builds a memoized single relationship to another Resource
          # by dynamically defining a method on the instance
          # with the given +rel_method+
          # ============================================
          #
          # class Wheel
          #   include Resource::Operations::Relationships
          #
          #   belongs_to :car, object_class: 'Car', mappings: { id: :car_id }
          #
          #   ...
          # end
          #
          # Wheel.new('id' => 4,  'car_id' => 1).
          #   car #=> EventbriteSDK::Car.retrieve('id' => 1)
          #
          # rel_method: Symbol of the method we are defining on this instance
          #             e.g. belongs_to :thing => defines self#thing
          # object_class: String representation of resource
          #               e.g. 'Event' => EventbriteSDK::Event
          #
          def belongs_to(rel_method, object_class: nil)
            define_method(rel_method) do
              query = { id: public_send(:"#{rel_method}_id") }

              relationships[rel_method] ||= begin
                resource_class_from_string(object_class).retrieve(query)
              end
            end
          end

          # Builds a memoized ResourceList relationship, dynamically defining
          # a method on the instance with the given +rel_method+
          # ============================================
          #
          # class Car
          #   include Resource::Operations::Relationships
          #
          #   has_many :wheels, object: 'Wheel', key: 'wheels'
          #
          #   def resource_path(postfix)
          #     "my_path/1/#{postfix}"
          #   end
          #
          #   ...
          # end
          #
          # Car.new('id' => '1').wheels
          #
          # Would instantiate a new ResourceList
          #
          # ResourceList.new(
          #   url_base: 'my_path/1/wheels',
          #   object_class: Wheel,
          #   key: :wheels
          # )
          #
          # rel_method: Symbol of the method we are defining on this instance
          # object_class: String representation of the Class we will give
          #               to ResourceList
          # key: key to use when ResourceList is extracting objects from
          #      a list payload, if nil then rel_method is used as a default
          #
          def has_many(rel_method, object_class: nil, key: nil)
            define_method(rel_method) do
              key ||= rel_method

              relationships[rel_method] ||= list_class(rel_method).new(
                url_base: path(rel_method),
                object_class: resource_class_from_string(object_class),
                key: key
              )
            end
          end
        end

        module InstanceMethods
          def list_class(resource_list_rel)
            class_name = resource_list_rel.to_s.split('_').map(&:capitalize).join
            class_name = "#{class_name}List"

            if Lists.const_defined?(class_name)
              Lists.const_get(class_name)
            else
              ResourceList
            end
          end

          private

          def relationships
            @_relationships ||= {}
          end
        end

        def self.included(receiver)
          receiver.extend ClassMethods
          receiver.send(:include, InstanceMethods)
        end
      end
    end
  end
end
