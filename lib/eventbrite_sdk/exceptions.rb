module EventbriteSDK
  class EventbriteAPIError < RuntimeError
    attr_reader :message, :response

    def initialize(msg = '', response = :none)
      @message = msg
      @response = response
    end

    # Returns a hash with AT LEAST 'error_description'.
    # When an error is raised manually there will be no response!
    # This is handled by using the specified message as the error_description.
    def parsed_error
      default = %({"error_description": "#{message}"})
      value = response_value(:body, fallback: default)

      JSON.parse(value)
    end

    # Returns the status code of the response, or :none if there is no response.
    def status_code
      response_value(:code)
    end

    private

    def response_value(key, fallback: :none)
      if response.respond_to?(key)
        response.send(key)
      else
        fallback
      end
    end
  end

  class BadRequest < EventbriteAPIError; end
  class Forbidden < EventbriteAPIError; end
  class InvalidAttribute < EventbriteAPIError; end
  class InternalServerError < EventbriteAPIError; end
  class ResourceNotFound < EventbriteAPIError; end
  class Unauthorized < EventbriteAPIError; end
end
