module EndpointStub
  def stub_endpoint(path: '', method: :get, status: 200, body: {})
    payload = body.is_a?(Symbol) ? file(body) : body.to_json

    path = "#{path}/" unless path.include?('?')

    stub_request(method, "https://www.eventbriteapi.com/v3/#{path}").
      to_return(body: payload, status: status)
  end

  def stub_get(path: '', fixture: nil, override: {})
    payload = JSON.parse(file(fixture)).merge!(override)

    stub_endpoint(path: path, method: :get, body: payload)
  end

  def stub_post_with_response(path: '', fixture: nil, override: {})
    payload = JSON.parse(file(fixture)).merge!(override)

    stub_endpoint(path: path, method: :post, body: payload)
  end

  def stub_delete(path: '')
    stub_endpoint(path: path, method: :delete, body: { 'deleted': true })
  end

  private

  def file(filename)
    path = File.join(File.dirname(__FILE__), '../fixtures', "#{filename}.json")
    File.read(path)
  end
end
