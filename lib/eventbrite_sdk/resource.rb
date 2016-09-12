module EventbriteSDK
  class Resource
    include Operations::AttributeSchema
    include Operations::Endpoint
    include Operations::Relationships
    include ActiveModel::Serialization

    attr_reader :primary_key

    def self.build(attrs)
      new.tap do |instance|
        instance.assign_attributes(attrs)
      end
    end

    def initialize(hydrated_attrs = {})
      reload hydrated_attrs
    end

    def new?
      !@primary_key
    end

    def refresh!(request = EventbriteSDK)
      if primary_key
        reload request.get(url: path)
      else
        false
      end
    end

    def inspect
      "#<#{self.class}: #{JSON.pretty_generate(@attrs.to_h)}>"
    end

    def save(postfixed_path = '', request = EventbriteSDK)
      if changed? || !postfixed_path.empty?
        response = request.post(url: path(postfixed_path),
                                payload: attrs.payload(self.class.prefix))

        reload(response)

        true
      end
    end

    def list_class
      ResourceList
    end

    private

    def resource_class_from_string(klass)
      EventbriteSDK.const_get(klass)
    end

    def reload(hydrated_attrs = {})
      @primary_key = hydrated_attrs.delete(
        self.class.path_opts[:primary_key].to_s
      )

      build_attrs(hydrated_attrs)
    end
  end
end
