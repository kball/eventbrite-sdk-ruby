module EventbriteSDK
  class ResourceList
    extend Forwardable
    include Enumerable

    def_delegators :@objects, :[], :each, :empty?

    def initialize(url_base: nil, object_class: nil, key: nil)
      @url_base = url_base
      @object_class = object_class
      @key = key
      @objects = []
      @pagination = {}
    end

    def retrieve(request = EventbriteSDK)
      response = request.get(url: url_base)
      @objects = (response[key.to_s] || []).map { |raw| object_class.new(raw) }
      @pagination = response['pagination'] || {}

      self
    end

    %i(object_count page_number page_size page_count).each do |method|
      define_method(method) { @pagination[method.to_s] }
    end

    private

    attr_reader :key,
                :object_class,
                :objects,
                :url_base
  end
end
