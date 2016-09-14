module EventbriteSDK
  class Organizer < Resource
    resource_path 'organizers/:id'

    attributes_prefix 'organizer'

    has_many :events, object_class: 'Event'

    schema_definition do
      string 'name'
      string 'description.html'
      string 'long_description.html'
      string 'logo.id'
      string 'website'
      string 'twitter'
      string 'facebook'
      string 'instagram'
    end
  end
end
