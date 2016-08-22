module EventbriteSDK
  class Event < Resource
    endpoint 'events/:id', primary_key: :id

    attributes_prefix 'event'

    schema_attributes do
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
    end

    # Defines event#cancel, event#publish, and event#unpublish
    #
    # When an event has an id the POST is made, otherwise we return false
    # POSTS to event/:id/(cancel|publish|unpublish)
    %i(cancel publish unpublish).each do |method|
      define_method(method) do
        !new? && save(method.to_s)
      end
    end
  end
end
