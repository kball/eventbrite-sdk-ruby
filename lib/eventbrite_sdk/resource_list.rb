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
      @url_base = url_base
      @object_class = object_class
      @key = key
      @objects = []
      @request = request
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
      @expansion = args.first && args.join(',')

      self
    end

    private

    def pagination
      @pagination ||= { 'page_count' => 1, 'page_number' => 1 }
    end

    def load_response
      query = { page: page_number }
      query[:expand] = expansion if expansion

      request.get(url: url_base, query: query)
    end

    attr_reader :expansion,
                :key,
                :object_class,
                :objects,
                :request,
                :url_base
  end
end
