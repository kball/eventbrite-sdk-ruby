module EventbriteSDK
  class EventbriteAPIError < RuntimeError
    attr_reader :message, :response

    def initialize(msg = '', response = :none)
      @message = msg
      @response = response
    end

    def parsed_error
      JSON.parse(response.body)
    end

    def status_code
      response.code
    end
  end

  class BadRequest < EventbriteAPIError; end
  class Forbidden < EventbriteAPIError; end
  class InvalidAttribute < EventbriteAPIError; end
  class ResourceNotFound < EventbriteAPIError; end
  class Unauthorized < EventbriteAPIError; end
end
