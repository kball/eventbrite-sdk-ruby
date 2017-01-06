module EventbriteSDK
  class Resource
    module Operations
      module Endpoint
        module ClassMethods
          attr_reader :path, :path_opts

          # Retrieve a resource.
          #
          # params: Hash of supported parameters. The keys and values are
          #         used to build the request URL by substituting supported
          #         keys in the resource_path with the value defined in params.
          #
          #         The :expand key allows the support of expansions of child
          #         objects. It supports strings, symbols and arrays.
          #
          #         expand: :something
          #         expand: %i(something another)
          #         expand: %w(something another)
          #         expand: 'something,another'
          #
          # Example:
          #
          # class Thing < Resource
          #   resource_path('things/:id')
          # end
          #
          # Thing.retrieve(id: 1234, expand: :others)
          #
          # This tells the resource to replace the :id placeholder with the
          # value 1234. It also will pass the :expand option with the
          def retrieve(params, request = EventbriteSDK)
            url_path = params.reduce(@path) do |path, (key, value)|
              path.gsub(":#{key}", value.to_s)
            end

            if params[:expand]
              query = { expand: [*params[:expand]].join(',') }
            end

            new request.get(url: url_path, query: query)
          end

          # Define the url path for the resource. It also implicitly defines
          # the primary key and any additional foreign keys required for this
          # resource.
          #
          # Example:
          #
          # TicketClass is a resource that requires a primary key of id and a
          # foreign key of event_id to be retrieved, modified or deleted.
          #
          # resource_path('events/:event_id/ticket_classes/:id')
          #
          # The resource now has #id and #event_id accessor methods, and
          # requires those parameters to build the correct resource url path.
          # See the retrieve method (above) for additional details.
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
              full_path += '/' unless full_path.end_with?('/')
              "#{full_path}#{postfixed_path}"
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
