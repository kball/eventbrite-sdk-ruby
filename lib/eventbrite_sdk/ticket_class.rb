module EventbriteSDK
  class TicketClass < Resource
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
      datetime 'sales_start.utc'
      datetime 'sales_start.timezone'
      datetime 'sales_end.utc'
      datetime 'sales_end.timezone'
      integer 'minimum_quantity'
      integer 'maximum_quantity'
      boolean 'auto_hide'
      boolean 'hidden'
      string 'order_confirmation_message'
    end
  end
end
