module EventbriteSDK
  class Event < Resource
    ERROR_CANNOT_PUBLISH = 'CANNOT_UNPUBLISH'.freeze
    ERROR_ALREADY_PUBLISHED_OR_DELETED = 'ALREADY_PUBLISHED_OR_DELETED'.freeze

    # Defines event#cancel, event#publish, and event#unpublish
    #
    # When an event has an id the POST is made, otherwise we return false
    # POSTS to event/:id/(cancel|publish|unpublish)
    define_api_actions :cancel, :publish, :unpublish

    resource_path 'events/:id'

    attributes_prefix 'event'

    belongs_to :organizer, object_class: 'Organizer'
    belongs_to :venue, object_class: 'Venue'

    has_many :orders, object_class: 'Order'
    has_many :ticket_classes, object_class: 'TicketClass'

    schema_definition do
      string 'name.html'
      string 'description.html'
      string 'organizer_id'
      datetime 'start.utc'
      datetime 'start.timezone'
      datetime 'end.utc'
      datetime 'end.timezone'
      boolean 'hide_start_date'
      boolean 'hide_end_date'
      string 'currency'
      string 'venue_id'
      boolean 'online_event'
      boolean 'listed'
      string 'logo_id'
      string 'category_id'
      string 'subcategory_id'
      string 'format_id'
      boolean 'shareable'
      boolean 'invite_only'
      string 'password'
      integer 'capacity'
      boolean 'show_remaining'
      string 'status', read_only: true
      string 'created', read_only: true
      string 'changed', read_only: true
      string 'resource_uri', read_only: true
    end

    def self.search(params)
      ResourceList.new(
        url_base: 'events/search',
        object_class: self,
        key: 'events',
        query: params
      )
    end

    def list!
      unless listed
        assign_attributes('listed' => false)
        save
      end
    end

    def unlist!
      if listed
        assign_attributes('listed' => false)
        save
      end
    end
  end
end
