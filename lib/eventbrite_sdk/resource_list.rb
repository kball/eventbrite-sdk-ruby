module EventbriteSDK
  class ResourceList
    extend Forwardable
    include Enumerable

    def_delegators :@objects, :[], :each, :empty?

    def initialize(
      url_base: nil,
      object_class: nil,
      key: nil,
      request: EventbriteSDK
    )
      @key = key
      @object_class = object_class
      @objects = []
      @query = {}
      @request = request
      @url_base = url_base
    end

    def retrieve
      response = load_response

      @objects = (response[key.to_s] || []).map { |raw| object_class.new(raw) }
      @pagination = response['pagination']

      self
    end

    def page(num)
      pagination['page_number'] = num

      retrieve
    end

    def next_page
      pagination['page_number'] += 1 unless page_number >= (page_count || 1)

      retrieve
    end

    def prev_page
      pagination['page_number'] -= 1 unless page_number <= 1

      retrieve
    end

    %w(object_count page_number page_size page_count).each do |method|
      define_method(method) { pagination[method] }
    end

    def to_json(opts = {})
      { key => objects.map(&:to_h), 'pagination' => @pagination }.to_json(opts)
    end

    def with_expansion(*args)
      if args.first
        @query[:expand] = args.join(',')
      else
        @query.delete(:expand)
      end

      self
    end

    private

    def pagination
      @pagination ||= { 'page_count' => 1, 'page_number' => 1 }
    end

    def load_response
      request.get(url: url_base, query: query.merge(page: page_number))
    end

    attr_reader :expansion,
                :key,
                :object_class,
                :objects,
                :query,
                :request,
                :url_base
  end
end
