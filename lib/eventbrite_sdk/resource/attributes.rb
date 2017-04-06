module EventbriteSDK
  class Resource
    class Attributes
      SISTER_FIELDS = {
        'timezone' => 'utc',
        'utc' => 'timezone'
      }.freeze

      attr_reader :attrs, :changes

      def self.build(attrs, schema)
        new({}, schema).tap do |instance|
          instance.assign_attributes(attrs)
        end
      end

      def initialize(hydrated_attrs = {}, schema = NullSchemaDefinition.new)
        @attrs = {}
        @changes = {}
        @schema = schema

        # Build out initial hash based on schema's defined keys
        schema.defined_keys.each { |key| bury_attribute(key, nil) }

        @attrs = attrs.merge(stringify_keys(hydrated_attrs))
      end

      def [](key)
        public_send(key)
      end

      def assign_attributes(new_attrs)
        stringify_keys(new_attrs).each do |attribute_key, value|
          assign_value(attribute_key, value) if schema.writeable?(attribute_key)
        end

        nil
      end

      def changed?
        changes.any?
      end

      def to_h
        attrs.to_h
      end

      def to_json(opts = {})
        to_h.to_json(opts)
      end

      def inspect
        "#<#{self.class}: #{JSON.pretty_generate(@attrs.to_h)}>"
      end

      def reset!
        changes.each do |attribute_key, (old_value, _current_value)|
          bury_attribute(attribute_key, old_value)
        end

        @changes = {}

        true
      end

      # Provides changeset in a format that can be thrown at an endpoint
      #
      # prefix: This is needed due to inconsistencies in the EB API
      #         Sometimes there's a prefix, sometimes there's not,
      #         sometimes it's singular, sometimes it's plural.
      #         Once the API gets a bit more nomalized we can remove this
      #         alltogether and infer a prefix based
      #         on the class name of the resource
      def payload(prefix = nil)
        changes.each_with_object({}) do |(attribute_key, (_, value)), payload|
          key = if prefix
                  "#{prefix}.#{attribute_key}"
                else
                  attribute_key
                end

          bury(key, value, payload)
        end
      end

      def values
        attrs.values
      end

      private

      attr_reader :schema

      def assign_value(attribute_key, value)
        dirty_check(attribute_key, value)
        add_rich_value(attribute_key)
        bury_attribute(attribute_key, value)
      end

      def dirty_check(attribute_key, value)
        initial_value = attrs.dig(*attribute_key.split('.'))

        if initial_value != value
          changes[attribute_key] = [initial_value, value]
        end
      end

      def bury_attribute(attribute_key, value)
        bury(attribute_key, value, attrs)
      end

      # Since we use dirty checking to determine what the payload is
      # you can run into a case where a "rich media" field needs other attrs
      # Namely timezone, so if a rich date changed, add the tz with it.
      def add_rich_value(attribute_key)
        if changes[attribute_key] && attribute_key =~ /\A(.+)\.(utc|timezone)\z/
          field = Regexp.last_match(2)
          key_prefix = Regexp.last_match(1)

          handle_sister_field(key_prefix, field)
        end
      end

      def bury(attribute_key, value, hash = {})
        keys = attribute_key.split '.'

        # Hand rolling #bury
        # hopefully we get it in the next release of Ruby
        keys.each_cons(2).reduce(hash) do |prev_attrs, (key, _)|
          prev_attrs[key] ||= {}
        end[keys.last] = value

        hash
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
        attrs.has_key?(method_name.to_s) || super
      end

      def handle_sister_field(key_prefix, field)
        sister_field = SISTER_FIELDS[field]
        stale_value = attrs.dig(key_prefix, sister_field)

        unless changes["#{key_prefix}.#{sister_field}"]
          changes["#{key_prefix}.#{sister_field}"] = [stale_value, stale_value]
        end
      end

      def handle_requested_attr(value)
        if value.is_a?(Hash)
          self.class.new(value)
        else
          value
        end
      end

      def stringify_keys(params)
        params.to_h.map { |key, value| [key.to_s, value] }.to_h
      end
    end
  end
end
