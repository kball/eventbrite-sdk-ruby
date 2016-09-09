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
      response = @request.get(url: url_base, query: { page: page_number })
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

    private

    def pagination
      @pagination ||= {
        'page_count' => 1,
        'page_number' => 1,
      }
    end

    attr_reader :key,
                :object_class,
                :objects,
                :url_base
  end
end
