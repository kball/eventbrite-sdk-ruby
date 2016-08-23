module EventbriteSDK
  class Order < Resource
    endpoint 'orders/:id', primary_key: :id

    belongs_to :event,
               object_class: 'Event',
               mappings: { id: :event_id }

    schema_attributes do
      string 'name'
      string 'first_name'
      string 'last_name'
      string 'email'
      string 'costs' # TODO object
      datetime 'created', read_only: true
      datetime 'changed', read_only: true
      string 'resource_uri', read_only: true
    end
  end
end
