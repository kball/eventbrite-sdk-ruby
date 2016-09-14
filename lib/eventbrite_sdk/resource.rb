module EventbriteSDK
  class Resource
    include Operations::AttributeSchema
    include Operations::Endpoint
    include Operations::Relationships

    def self.build(attrs)
      new.tap do |instance|
        instance.assign_attributes(attrs)
      end
    end

    def initialize(hydrated_attrs = {})
      reload hydrated_attrs
    end

    def new?
      !id
    end

    def refresh!(request = EventbriteSDK)
      unless new?
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

    def self.define_api_actions(*actions)
      @api_actions = actions
    end

    def self.api_actions
      @api_actions || []
    end

    def resource_class_from_string(klass)
      EventbriteSDK.const_get(klass)
    end

    def reload(hydrated_attrs = {})
      build_attrs(hydrated_attrs)
    end

    def call_api_action(api_action)
      !new? && save(api_action_real_name(api_action))
    end

    def method_missing(method_name, *_args, &_block)
      if api_action_defined?(method_name)
        call_api_action(method_name)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      api_action_defined?(method_name) || super
    end

    def api_action_defined?(method_name)
      self.class.api_actions.include?(method_name) ||
        api_action_name_aliased?(method_name)
    end

    def api_action_name_aliased?(api_action)
      self.class.api_actions.any? { |action|
        action.is_a?(Hash) && action.key?(api_action)
      }
    end

    def api_action_real_name(api_action)
      if api_action_name_aliased? api_action
        self.class.api_actions.find { |action|
          action.is_a?(Hash) && action.key?(api_action)
        }[api_action]
      else
        api_action
      end.to_s
    end
  end
end
