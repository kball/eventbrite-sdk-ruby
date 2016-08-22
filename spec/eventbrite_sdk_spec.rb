require 'spec_helper'

describe EventbriteSDK do
  after(:each) do
    Thread.current[described_class::THREAD_KEY] = nil
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

  describe '.token=' do
    it 'sets given token to the current thread' do
      token = 'token'

      described_class.token = token

      expect(Thread.current[described_class::THREAD_KEY]).to eq(token)
    end
  end

  describe '.token' do
    context 'when token is set' do
      it 'returns the value from the current thread' do
        Thread.current[described_class::THREAD_KEY] = 'value'

        expect(described_class.token).to eq('value')
      end
    end

    context 'when token is not set' do
      it 'returns nil' do
        expect(described_class.token).to be_nil
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
          headers: { 'Authorization' => "Bearer #{token}" },
          accept: :json,
        )
      end
    end

    context 'without token' do
      it 'raises EventbriteSDK::AuthenticationError' do
        expect do
          described_class.get(url: "events/1")
        end.to raise_error(described_class::AuthenticationError)
      end
    end
  end
end
