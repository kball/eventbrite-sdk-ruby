require 'json'
require 'set'
require 'rest_client'

require 'eventbrite_sdk/version'
require 'eventbrite_sdk/exceptions'
require 'eventbrite_sdk/resource/operations/attribute_schema'
require 'eventbrite_sdk/resource/operations/endpoint'
require 'eventbrite_sdk/resource/attributes'
require 'eventbrite_sdk/resource/null_schema'
require 'eventbrite_sdk/resource/schema'
require 'eventbrite_sdk/resource_list'
require 'eventbrite_sdk/resource'

require 'eventbrite_sdk/event'
require 'eventbrite_sdk/order'
require 'eventbrite_sdk/organizer'
require 'eventbrite_sdk/user'

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
    }
  }.freeze
  THREAD_KEY = :eb_api_token

  def self.token
    Thread.current[THREAD_KEY]
  end

  def self.token=(api_token)
    Thread.current[THREAD_KEY] = api_token
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
          url: url(params[:url]),
          headers: { 'Authorization' => "Bearer #{token}" },
          accept: :json,
        }

        request[:payload] = params[:payload] if params[:method] == :post

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
    "#{BASE}/#{path}/"
  end

  def self.resource(resource_name)
    const_get(resource_name)
  end
end
