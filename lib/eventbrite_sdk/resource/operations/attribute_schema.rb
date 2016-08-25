module EventbriteSDK
  class Resource
    module Operations
      module AttributeSchema
        module ClassMethods
          attr_reader :prefix, :schema

          def schema_definition(&block)
            @schema = SchemaDefinition.new(name)
            @schema.instance_eval(&block)
          end

          def attributes_prefix(prefix)
            @prefix = prefix
          end
        end

        module InstanceMethods
          %i(changes changed?).each do |method|
            define_method(method) { attrs.public_send(method) }
          end

          %i([] assign_attributes).each do |method|
            define_method(method) { |arg| attrs.public_send(method, arg) }
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

          def build_attrs(new_attrs)
            @attrs = Attributes.new(new_attrs, self.class.schema)
          end

          private

          attr_reader :attrs
        end

        def self.included(receiver)
          receiver.extend ClassMethods
          receiver.prepend InstanceMethods
        end
      end
    end
  end
end
