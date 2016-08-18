module EventbriteSDK
  class Resource
    extend Forwardable
    def_delegators :@attrs, :changes, :changed?, :assign_attributes, :[]

    attr_reader :primary_key

    class << self
      attr_reader :endpoint, :endpoint_opts, :prefix, :schema

      def endpoint(endpoint, opts = {})
        @endpoint_opts = opts
        @endpoint = endpoint
      end

      def endpoint_path(value)
        @endpoint.gsub(":#{endpoint_opts[:primary_key]}", value)
      end

      def schema_attributes(&block)
        @schema = Schema.new(name)
        @schema.instance_eval(&block)
      end

      def attributes_prefix(prefix)
        @prefix = prefix
      end

      def find(params)
        response = EventbriteSDK.get url: url_endpoint_from_params(params)

        new response
      end

      def url_endpoint_from_params(params)
        params.reduce(@endpoint) do |resource_endpoint, (key, value)|
          resource_endpoint.gsub(":#{key}", value)
        end
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

    def refresh!
      if primary_key
        response = EventbriteSDK.get(url: endpoint_path)
        @attrs = Attributes.new(response, self.class.schema)
      else
        false
      end
    end

    def endpoint_path
      sub_value = primary_key || ''

      # Strip off any trailing slash as EventbriteSDK.request adds it
      self.class.endpoint_path(sub_value).gsub(/\/$/, '')
    end

    def full_endpoint_url
      EventbriteSDK.url endpoint_path
    end

    def inspect
      "#<#{self.class}: #{JSON.pretty_generate(@attrs.to_h)}>"
    end

    def save
      if changed?
        response = EventbriteSDK.post(url: endpoint_path,
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

    def method_missing(method_name, *_args, &_block)
      if attrs.respond_to?(method_name)
        attrs.public_send(method_name)
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      attrs.respond_to_missing?(method_name)
    end
  end
end
