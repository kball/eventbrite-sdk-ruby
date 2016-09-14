module EventbriteSDK
  class Webhook < Resource
    resource_path 'webhooks/:id'

    schema_definition do
      string 'endpoint_url'
      string 'event_id'
      string 'actions'
    end
  end
end
