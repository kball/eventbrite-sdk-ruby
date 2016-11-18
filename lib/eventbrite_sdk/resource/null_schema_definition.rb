module EventbriteSDK
  class Resource
    class NullSchemaDefinition
      def writeable?(_key)
        true
      end

      def defined_keys
        []
      end
    end
  end
end
