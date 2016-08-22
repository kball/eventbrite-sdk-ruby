module EndpointStub
  def stub_endpoint(path: '', method: :get, status: 200, body: {})
    payload = body.is_a?(Symbol) ? file(body) : body.to_json

    stub_request(method, "https://www.eventbriteapi.com/v3/#{path}").
      to_return(body: payload, status: status)
  end

  private

  def file(filename)
    path = File.join(File.dirname(__FILE__), '../fixtures', "#{filename}.json")
    File.read(path)
  end
end
