module EventbriteSDK
  class Venue < Resource
    resource_path 'venues/:id', primary_key: :id

    attributes_prefix 'venue'

    belongs_to :organizer,
               object_class: 'Organizer',
               mappings: { id: :organizer_id }

    schema_definition do
      string 'name'
      string 'address.latitude'
      string 'address.longitude'
      string 'organizer_id'
      string 'address.address_1'
      string 'address.address_2'
      string 'address.city'
      string 'address.region'
      string 'address.postal_code'
      string 'address.country'
    end
  end
end
