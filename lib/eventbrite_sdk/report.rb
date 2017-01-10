module EventbriteSDK
  class Report
    STRING_KEYS = %i(
      start_date
      end_date
      date_facet
      event_status
      timezone
      group_by
    ).freeze

    VALID_REPORTS = %i(attendees sales).freeze

    def initialize
      @query = {}
    end

    def event_ids(*ids)
      @query[:event_ids] = ids.join(',')

      self
    end

    def filter_by(filters)
      @query[:filter_by] = filters.to_json

      self
    end

    STRING_KEYS.each do |method|
      define_method(method) do |value|
        @query[method] = value
        self
      end
    end

    def query
      @query.dup # Don't allow mutation
    end

    def retrieve(type = nil, sdk = EventbriteSDK)
      unless VALID_REPORTS.include?(type)
        raise ArgumentError, "`:type` is not of #{VALID_REPORTS}"
      end

      sdk.get(url: "reports/#{type}", query: query)
    end
  end
end
