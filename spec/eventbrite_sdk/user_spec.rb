require 'spec_helper'

module EventbriteSDK
  RSpec.describe User do
    describe '.me' do
      it 'returns a new instance with #id as "me"' do
        user = described_class.me

        expect(user.id).to eq('me')
      end
    end
  end
end
