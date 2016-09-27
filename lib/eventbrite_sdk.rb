require 'json'
require 'set'
require 'rest_client'

require 'eventbrite_sdk/version'
require 'eventbrite_sdk/exceptions'
require 'eventbrite_sdk/resource/operations/attribute_schema'
require 'eventbrite_sdk/resource/operations/endpoint'
require 'eventbrite_sdk/resource/operations/relationships'
require 'eventbrite_sdk/resource/attributes'
require 'eventbrite_sdk/resource/null_schema_definition'
require 'eventbrite_sdk/resource/schema_definition'
require 'eventbrite_sdk/resource_list'
require 'eventbrite_sdk/resource'

require 'eventbrite_sdk/lists/owned_event_orders_list'

require 'eventbrite_sdk/attendee'
require 'eventbrite_sdk/event'
require 'eventbrite_sdk/media'
require 'eventbrite_sdk/order'
require 'eventbrite_sdk/organizer'
require 'eventbrite_sdk/ticket_class'
require 'eventbrite_sdk/user'
require 'eventbrite_sdk/venue'
require 'eventbrite_sdk/webhook'

module EventbriteSDK
  BASE = "https://www.eventbriteapi.com/v#{VERSION.split('.').first}".freeze
  EXCEPTION_MAP = {
    RestClient::ResourceNotFound => {
      class: ResourceNotFound,
      message: 'requested object was not found',
    },
    RestClient::BadRequest => {
      class: BadRequest,
      message: 'invalid request',
    },
    RestClient::Forbidden => {
      class: Forbidden,
      message: 'not authorized',
    },
    RestClient::Unauthorized => {
      class: Unauthorized,
      message: 'unauthorized request',
    }
  }.freeze
  THREAD_EB_API_TOKEN_KEY = :eb_api_token
  THREAD_BASE_URL_KEY = :base_url

  def self.token
    Thread.current[THREAD_EB_API_TOKEN_KEY]
  end

  def self.token=(api_token)
    Thread.current[THREAD_EB_API_TOKEN_KEY] = api_token
  end

  def self.base_url
    Thread.current[THREAD_BASE_URL_KEY] || BASE
  end

  def self.base_url=(url)
    Thread.current[THREAD_BASE_URL_KEY] = url
  end

  def self.get(params)
    request(params.merge(method: :get))
  end

  def self.post(params)
    request(params.merge(method: :post))
  end

  def self.request(params)
    if token
      begin
        request = {
          method: params[:method],
          url: url(params[:url].gsub(/\/$/, '')),
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{token}",
          },
        }

        request[:headers][:params] = params[:query] if params[:query]

        if params[:method] == :post
          request[:payload] = params[:payload].to_json
          request[:headers]['Content-Type'] = 'application/json'
        end

        response = RestClient::Request.execute(request)

        JSON.parse(response.body)
      rescue *EXCEPTION_MAP.keys => err
        handler = EXCEPTION_MAP[err.class]
        raise handler[:class].new(handler[:message], err.response)
      end
    else
      raise AuthenticationError, 'you must provide a token to use the API'
    end
  end

  def self.url(path)
    "#{base_url}/#{path}/"
  end
end
