module EventbriteSDK
  class Resource
    class Attributes
      attr_reader :attrs, :changes

      def self.build(attrs, schema)
        new({}, schema).tap do |instance|
          instance.assign_attributes(attrs)
        end
      end

      def initialize(hydrated_attrs = {}, schema = NullSchema.new)
        @attrs = hydrated_attrs
        @schema = schema
        @changes = {}
      end

      def [](key)
        public_send(key)
      end

      def assign_attributes(new_attrs)
        new_attrs.each do |attribute_key, value|
          if schema.writeable?(attribute_key)
            assign_value(attribute_key, value)
          end
        end

        nil
      end

      def changed?
        changes.any?
      end

      def to_h
        attrs.to_h
      end

      def inspect
        "#<#{self.class}: #{JSON.pretty_generate(@attrs.to_h)}>"
      end

      def reset!
        changes.each do |attribute_key, (old_value, _current_value)|
          bury(attribute_key, old_value)
        end

        @changes = {}

        true
      end

      def payload(prefix = nil)
        changes.each_with_object({}) do |(attribute_key, (_, value)), payload|
          key = if prefix
                  "#{prefix}.#{attribute_key}"
                else
                  attribute_key
                end

          payload[key] = value
        end
      end

      private

      attr_reader :schema

      def assign_value(attribute_key, value)
        dirty_check(attribute_key, value)
        bury(attribute_key, value)
      end

      def dirty_check(attribute_key, value)
        initial_value = attrs.dig(*attribute_key.split('.'))

        if initial_value != value
          changes[attribute_key] = [initial_value, value]
        end
      end

      def bury(attribute_key, value)
        keys = attribute_key.split '.'

        # Hand rolling #bury
        # hopefully we get it in the next release of Ruby
        keys.each_cons(2).reduce(attrs) do |prev_attrs, (key, _)|
          prev_attrs[key] ||= {}
        end[keys.last] = value
      end

      def method_missing(method_name, *_args, &_block)
        requested_key = method_name.to_s

        if attrs.has_key?(requested_key)
          handle_requested_attr(attrs[requested_key])
        else
          super
        end
      end

      def respond_to_missing?(method_name, _include_private = false)
        attrs.has_key?(method_name.to_s)
      end

      def handle_requested_attr(value)
        if value.is_a?(Hash)
          self.class.new(value)
        else
          value
        end
      end
    end
  end
end
