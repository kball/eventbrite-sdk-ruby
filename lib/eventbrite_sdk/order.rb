module EventbriteSDK
  class Order < Resource
    resource_path 'orders/:id'

    # Defines order#resend_confirmation_email and order#refund
    #
    # When an event has an id the POST is made, otherwise we return false
    # POSTS to order/:id/(resend_confirmation_email|refunds)
    define_api_actions :resend_confirmation_email, { refund: :refunds }

    belongs_to :event, object_class: 'Event'

    schema_definition do
      string 'name'
      string 'first_name'
      string 'last_name'
      string 'email'
      string 'costs'
      datetime 'created', read_only: true
      datetime 'changed', read_only: true
      string 'resource_uri', read_only: true
    end
  end
end
