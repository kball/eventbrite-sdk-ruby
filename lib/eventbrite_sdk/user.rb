module EventbriteSDK
  class User < Resource
    resource_path 'users/:id'

    has_many :owned_events, object_class: 'Event', key: :events
    has_many :organizers, object_class: 'Organizer', key: :organizers

    schema_definition do
      string 'name'
      string 'first_name'
      string 'last_name'
      string 'emails'
      string 'image_id'
    end
  end
end
