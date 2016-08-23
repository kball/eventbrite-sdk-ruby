module EventbriteSDK
  class Resource
    include Operations::AttributeSchema
    include Operations::Endpoint

    attr_reader :primary_key

    class << self
      def retrieve(params, repo = EventbriteSDK)
        response = repo.get url: url_endpoint_from_params(params)

        new response
      end

      def build(attrs)
        new.tap do |instance|
          instance.assign_attributes(attrs)
        end
      end

      def belongs_to(rel_method, object_class: nil, mappings: nil)
        define_method(rel_method) do
          keys = mappings.each_with_object({}) do | (key, method), hash|
            hash[key.to_s] = public_send(method)
          end

          @relationships[rel_method] ||= begin
              EventbriteSDK.resource(object_class).retrieve(keys)
          end
        end
      end

      def has_many(rel_method, object_class: nil, key: nil)
        define_method(rel_method) do
          @relationships[rel_method] ||= ResourceList.new(
            url_base: endpoint_path(rel_method),
            object_class: EventbriteSDK.resource(object_class),
            key: key || rel_method
          )
        end
      end
    end

    def initialize(hydrated_attrs = {})
      reload(hydrated_attrs)
      @relationships = {}
    end

    def new?
      !@primary_key
    end

    def refresh!(repo = EventbriteSDK)
      if primary_key
        response = repo.get(url: endpoint_path)
        @attrs = Attributes.new(response, self.class.schema)
      else
        false
      end
    end

    def inspect
      "#<#{self.class}: #{JSON.pretty_generate(@attrs.to_h)}>"
    end

    def save(postfixed_path = '', repo = EventbriteSDK)
      if changed? || !postfixed_path.empty?
        response = repo.post(url: endpoint_path(postfixed_path),
                             payload: attrs.payload(self.class.prefix))

        reload(response)

        true
      end
    end

    private

    attr_reader :attrs

    def reload(hydrated_attrs = {})
      @primary_key = hydrated_attrs.delete(
        self.class.endpoint_opts[:primary_key].to_s
      )
      @attrs = Attributes.new(hydrated_attrs, self.class.schema)
    end
  end
end
