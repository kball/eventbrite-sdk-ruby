module EventbriteSDK
  class Resource
    include Operations::AttributeSchema
    include Operations::Endpoint

    attr_reader :primary_key

    class << self
      def find(params, repo = EventbriteSDK)
        response = repo.get url: url_endpoint_from_params(params)

        new response
      end

      def build(attrs)
        new.tap do |instance|
          instance.assign_attributes(attrs)
        end
      end
    end

    def initialize(hydrated_attrs = {})
      reload(hydrated_attrs)
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
