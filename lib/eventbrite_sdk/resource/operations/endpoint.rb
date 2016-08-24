module EventbriteSDK
  class Resource
    module Operations
      module Endpoint
        module ClassMethods
          attr_reader :endpoint, :endpoint_opts

          def retrieve(params, request = EventbriteSDK)
            new request.get(url: url_endpoint_from_params(params))
          end

          def endpoint(endpoint, opts = {})
            @endpoint_opts = opts
            @endpoint = endpoint
          end

          def endpoint_path(value)
            @endpoint.gsub(":#{endpoint_opts[:primary_key]}", value)
          end

          def url_endpoint_from_params(params)
            params.reduce(@endpoint) do |resource_endpoint, (key, value)|
              resource_endpoint.gsub(":#{key}", value)
            end
          end
        end

        module InstanceMethods
          def endpoint_path(postfixed_path = '')
            sub_value = primary_key || ''

            # Strip off any trailing slash as EventbriteSDK.request adds it
            full_path = self.class.endpoint_path(sub_value).gsub(/\/$/, '')

            if postfixed_path.empty?
              full_path
            else
              "#{full_path}/#{postfixed_path}"
            end
          end

          def full_endpoint_url(sdk = EventbriteSDK)
            sdk.url endpoint_path
          end
        end

        def self.included(receiver)
          receiver.extend ClassMethods
          receiver.send(:include, InstanceMethods)
        end
      end
    end
  end
end
