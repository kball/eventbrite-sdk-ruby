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

          def resource_path(path)
            @path = path

            path.scan(/:\w+/).each do |path_attr|
              attr = path_attr.delete(':').to_sym

              define_method(attr) do
                @attrs[attr] if @attrs.respond_to?(attr)
              end
            end
         end
        end

        module InstanceMethods
          def path(postfixed_path = '')
            resource_path = self.class.path.dup
            tokens = resource_path.scan(/:\w+/)

            full_path = tokens.reduce(resource_path) do |path_frag, token|
              method = token.delete(':')
              path_frag.gsub(token, send(method).to_s)
            end

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
