module EventbriteSDK
  class Resource
    module Operations
      module AttributeSchema
        module ClassMethods
          attr_reader :prefix, :schema

          def schema_attributes(&block)
            @schema = Schema.new(name)
            @schema.instance_eval(&block)
          end

          def attributes_prefix(prefix)
            @prefix = prefix
          end
        end

        module InstanceMethods
          def changes
            attrs.changes
          end

          def changed?
            attrs.changed?
          end

          def [](key)
            attrs.public_send(key)
          end

          def assign_attributes(new_attrs)
            attrs.assign_attributes(new_attrs)
          end

          def method_missing(method_name, *_args, &_block)
            if attrs.respond_to?(method_name)
              attrs.public_send(method_name)
            else
              super
            end
          end

          def respond_to_missing?(method_name, _include_private = false)
            attrs.respond_to_missing?(method_name) || super
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
