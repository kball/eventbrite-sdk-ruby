module EventbriteSDK
  class Resource
    module Operations
      module Endpoint
        module ClassMethods
          attr_reader :path, :path_opts

          def retrieve(params, request = EventbriteSDK)
            url_path = params.reduce(@path) do |path, (key, value)|
              path.gsub(":#{key}", value.to_s)
            end

            new request.get(url: url_path)
          end

          def resource_path(path, opts = {})
            @path = path
            @path_opts = opts
          end

          def generate_path(value)
            @path.gsub(":#{path_opts[:primary_key]}", value)
          end
        end

        module InstanceMethods
          def path(postfixed_path = '')
            sub_value = primary_key || ''

            # Strip off any trailing slash as EventbriteSDK.request adds it
            full_path = self.class.generate_path(sub_value).gsub(/\/$/, '')

            if postfixed_path.empty?
              full_path
            else
              "#{full_path}/#{postfixed_path}"
            end
          end

          def full_url(request = EventbriteSDK)
            request.url path
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
