module EventbriteSDK
  # An Empty resource listing, returned on ORM calls from new resources
  class BlankResourceList
    extend Forwardable
    include Enumerable

    def_delegators :@objects, :[], :each, :empty?

    def initialize(key: nil)
      @key = key
      @objects = []
    end

    %i(
      next_page
      prev_page
      retrieve
    ).each do |method|
      define_method(method) { self }
    end

    def page(_num)
      self
    end

    def with_expansion(*_args)
      self
    end

    def to_json(opts = {})
      { @key => [] }.to_json(opts)
    end
  end
end
