module EventbriteSDK
  class Resource
    include Operations::AttributeSchema
    include Operations::Endpoint

    attr_reader :primary_key

    def self.build(attrs)
      new.tap do |instance|
        instance.assign_attributes(attrs)
      end
    end

    def self.belongs_to(rel_method, object_class: nil, mappings: nil)
      define_method(rel_method) do
        keys = mappings.each_with_object({}) do | (key, method), hash|
          hash[key.to_s] = public_send(method)
        end

        @relationships[rel_method] ||= begin
            EventbriteSDK.resource(object_class).retrieve(keys)
        end
      end
    end

    def self.has_many(rel_method, object_class: nil, key: nil)
      define_method(rel_method) do
        key ||= rel_method

        @relationships[rel_method] ||= ResourceList.new(
          url_base: endpoint_path(rel_method),
          object_class: EventbriteSDK.resource(object_class),
          key: key
        )
      end
    end

    def initialize(hydrated_attrs = {})
      reload hydrated_attrs
      @relationships = {}
    end

    def new?
      !@primary_key
    end

    def refresh!(request = EventbriteSDK)
      if primary_key
        reload request.get(url: endpoint_path)
      else
        false
      end
    end

    def inspect
      "#<#{self.class}: #{JSON.pretty_generate(@attrs.to_h)}>"
    end

    def save(postfixed_path = '', request = EventbriteSDK)
      if changed? || !postfixed_path.empty?
        response = request.post(url: endpoint_path(postfixed_path),
                                payload: attrs.payload(self.class.prefix))

        reload(response)

        true
      end
    end

    private

    def reload(hydrated_attrs = {})
      @primary_key = hydrated_attrs.delete(
        self.class.endpoint_opts[:primary_key].to_s
      )
      build_attrs(hydrated_attrs, self.class.schema)
    end
  end
end
