module EventbriteSDK
  class TicketClass < Resource
    ON_SALE_STATUS_AVAILABLE = 'AVAILABLE'.freeze

    resource_path 'events/:event_id/ticket_classes/:id'

    belongs_to :event, object_class: 'Event'

    attributes_prefix 'ticket_class'

    schema_definition do
      string 'name'
      string 'description'
      integer 'quantity_total'
      currency 'cost'
      currency 'fee', read_only: true
      currency 'tax', read_only: true
      boolean 'free'
      boolean 'include_fee'
      boolean 'split_fee'
      string 'sales_channels' # TODO list
      datetime 'sales_start'
      datetime 'sales_end'
      integer 'minimum_quantity'
      integer 'maximum_quantity'
      boolean 'auto_hide'
      boolean 'hidden'
      string 'order_confirmation_message'
    end

    def available?
      respond_to?(:on_sale_status) && on_sale_status == ON_SALE_STATUS_AVAILABLE
    end

    def hide!
      if hidden
        assign_attributes('hidden' => false)
        save
      end
    end

    def unhide!
      unless hidden
        assign_attributes('hidden' => true)
        save
      end
    end
  end
end
