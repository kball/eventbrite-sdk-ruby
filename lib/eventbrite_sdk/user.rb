module EventbriteSDK
  class User < Resource
    # Defines user#verify and user#unverify
    #
    # An user logged using Eventbrite we should generate a verification action
    # NOTE: only selected users can verify/unverify other users.
    # POSTS to users/:id/(verify|unverify)
    define_api_actions :verify, :unverify

    resource_path 'users/:id'

    has_many :organizers, object_class: 'Organizer', key: :organizers
    has_many :owned_event_orders, object_class: 'Order', key: :orders
    has_many :owned_events, object_class: 'Event', key: :events

    schema_definition do
      string 'name'
      string 'first_name'
      string 'last_name'
      string 'emails'
      string 'image_id'
    end

    def self.me
      new('id' => 'me')
    end
  end
end
