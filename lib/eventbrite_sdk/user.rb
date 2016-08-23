module EventbriteSDK
  class User < Resource
    endpoint 'users/:id', primary_key: :id

    has_many :owned_events, object_class: 'Event', key: :events
    has_many :organizers, object_class: 'Organizer', key: :organizers

    schema_attributes do
      string 'name'
      string 'first_name'
      string 'last_name'
      string 'emails'
      string 'image_id'
    end
  end
end
