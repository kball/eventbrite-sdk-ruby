module EventbriteSDK
  class EventbriteAPIError < StandardError
    def initialize(msg = '', response = :none)
      @msg = msg
      @response = response
    end

    def json_error
      JSON.parse(@response)
    end
  end

  class AuthenticationError < EventbriteAPIError; end
  class BadRequest < EventbriteAPIError; end
  class InvalidAttribute < EventbriteAPIError; end
  class ResourceNotFound < EventbriteAPIError; end
end
