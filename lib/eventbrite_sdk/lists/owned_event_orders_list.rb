module EventbriteSDK
  module Lists
    class OwnedEventOrdersList < ResourceList
      def search(term)
        send(:"term_provided_#{!!term}", term)

        @pagination = { 'page_count' => 1, 'page_number' => 1 }

        self
      end

      private

      # Swaps the endpoint out to allow searches
      def term_provided_true(term)
        @url_base.sub!('owned_event_orders', 'search_owned_event_orders')
        @query[:search_term] = term
      end

      # Swaps the endpoint out owned events, and removes the search_term query
      def term_provided_false(_term)
        @url_base.sub!('search_owned_event_orders', 'owned_event_orders')
        @query.delete(:search_term)
      end
    end
  end
end
