module EventbriteSDK
  class Resource
    class SchemaDefinition
      def initialize(resource_name)
        @resource_name = resource_name
        @read_only_keys = Set.new
        @attrs = {}
      end

      %i(boolean currency datetime integer string).each do |method|
        define_method(method) do |value, *opts|
          options = opts.first

          @read_only_keys << value if options && options[:read_only]
          @attrs[value] = method
        end
      end

      def writeable?(key)
        whitelisted_attribute?(key) && !read_only?(key)
      end

      def type(key)
        attrs[key]
      end

      private

      attr_reader :read_only_keys, :resource_name, :attrs

      def read_only?(key)
        read_only_keys.member?(key)
      end

      def whitelisted_attribute?(key)
        if attrs.has_key?(key)
          true
        else
          raise InvalidAttribute.new(
            "attribute `#{key}` not present in #{resource_name}"
          )
        end
      end
    end
  end
end
