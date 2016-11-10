require 'spec_helper'

describe EventbriteSDK do
  after(:each) do
    Thread.current[described_class::THREAD_EB_API_TOKEN_KEY] = nil
    described_class.base_url = described_class::BASE
    described_class.verify_ssl = described_class::VERIFY_SSL
  end

  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '::BASE' do
    it 'returns uri with MAJOR version after the `v`' do
      major = described_class::VERSION.split('.').first

      expect(described_class::BASE).to eq(
        "https://www.eventbriteapi.com/v#{major}"
      )
    end
  end

  describe '.base_url=' do
    it 'sets given base_url to the current thread' do
      base_url = 'value'

      described_class.base_url = base_url

      expect(described_class.base_url).to eq(base_url)
    end
  end

  describe '.base_url' do
    context 'when base_url is set' do
      it 'returns the value from the current thread' do
        described_class.base_url = 'value'

        expect(described_class.base_url).to eq('value')
      end
    end

    context 'when base_url is not set' do
      it 'returns nil' do
        expect(described_class.base_url).to eq(described_class::BASE)
      end
    end
  end

  describe '.get' do
    context 'with token' do
      it 'sets the Authorization header with the given api token' do
        token = 'token'
        described_class.token = token
        response = double(body: { hey: 'there' }.to_json)
        allow(RestClient::Request).to receive(:execute).and_return(response)

        described_class.get(url: 'events/1')

        expect(RestClient::Request).to have_received(:execute).with(
          method: :get,
          url: "#{described_class::BASE}/events/1/",
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{token}"
          },
          verify_ssl: true
        )
      end
    end

    context 'with a bad token' do
      it 'sets the Authorization header with the given api token' do
        stub_endpoint(path: 'events/1', status: 401)

        token = 'token'
        described_class.token = token

        expect do
          described_class.get(url: 'events/1')
        end.to raise_error(described_class::Unauthorized)
      end
    end

    context 'without token' do
      it 'raises EventbriteSDK::AuthenticationError' do
        stub_endpoint(path: 'events/1', status: 401, body: :no_token)

        expect do
          described_class.get(url: 'events/1')
        end.to raise_error(described_class::Unauthorized)
      end
    end
  end

  describe '.post' do
    context 'with token' do
      it 'sets Content-Type, Authorization headers with the given api token' do
        token = 'token'
        described_class.token = token
        response = double(body: { hey: 'there' }.to_json)
        payload = { 'name' => 'foo' }

        allow(RestClient::Request).to receive(:execute).and_return(response)

        described_class.post(payload: payload, url: 'events/1')

        expect(RestClient::Request).to have_received(:execute).with(
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{token}"
          },
          method: :post,
          payload: payload.to_json,
          url: "#{described_class::BASE}/events/1/",
          verify_ssl: true,
        )
      end
    end

    context 'with a bad token' do
      it 'sets the Authorization header with the given api token' do
        stub_endpoint(method: :post, path: 'events/1', status: 401)

        token = 'token'
        described_class.token = token

        expect do
          described_class.post(payload: { 'foo' => 'bar' }, url: 'events/1')
        end.to raise_error(described_class::Unauthorized)
      end
    end

    context 'without token' do
      it 'raises EventbriteSDK::AuthenticationError' do
        stub_endpoint(
          body: :no_token, method: :post, path: 'events/1', status: 401
        )

        expect do
          described_class.post(payload: { 'a' => 'choo' }, url: 'events/1')
        end.to raise_error(described_class::Unauthorized)
      end
    end
  end

  describe '.token=' do
    it 'sets given token to the current thread' do
      token = 'token'

      described_class.token = token

      expect(Thread.current[described_class::THREAD_EB_API_TOKEN_KEY]).to eq(token)
    end
  end

  describe '.token' do
    context 'when token is set' do
      it 'returns the value from the current thread' do
        Thread.current[described_class::THREAD_EB_API_TOKEN_KEY] = 'value'

        expect(described_class.token).to eq('value')
      end
    end

    context 'when token is not set' do
      it 'returns nil' do
        expect(described_class.token).to be_nil
      end
    end
  end

  describe '.verify_ssl?' do
    context 'when verify_ssl is set' do
      it 'returns the given value' do
        described_class.verify_ssl = false

        expect(described_class).not_to be_verify_ssl
      end
    end

    context 'when verify_ssl is not set' do
      it 'returns default constant' do
        expect(described_class.verify_ssl?).to eq(true)
      end
    end
  end
end
