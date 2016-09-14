module EventbriteSDK
  class Event < Resource
    # Defines event#cancel, event#publish, and event#unpublish
    #
    # When an event has an id the POST is made, otherwise we return false
    # POSTS to event/:id/(cancel|publish|unpublish)
    define_api_actions :cancel, :publish, :unpublish

    resource_path 'events/:id', primary_key: :id

    attributes_prefix 'event'

    has_many :orders, object_class: 'Order'
    belongs_to :organizer,
               object_class: 'Organizer',
               mappings: { id: :organizer_id }
    belongs_to :venue,
               object_class: 'Venue',
               mappings: { id: :venue_id }

    schema_definition do
      string 'name.html'
      string 'description.html'
      string 'organizer_id'
      datetime 'start.utc'
      string 'start.timezone'
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
      string 'created', read_only: true
      string 'changed', read_only: true
      string 'resource_uri', read_only: true
    end
  end
end
