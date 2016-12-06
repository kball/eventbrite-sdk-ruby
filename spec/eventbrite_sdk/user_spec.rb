require 'spec_helper'

module EventbriteSDK
  RSpec.describe User do
    describe '.me' do
      it 'returns a new instance with #id as "me"' do
        user = described_class.me

        expect(user.id).to eq('me')
      end
    end

    describe '#verify' do
      context 'when id exists' do
        it 'calls save with `verify`' do
          user = described_class.new('id' => '1')
          allow(user).to receive(:save)

          user.verify

          expect(user).to have_received(:save).with('verify')
        end
      end

      context 'when id is absent' do
        it 'returns false' do
          user = described_class.new
          allow(user).to receive(:save)

          expect(user.verify).to eq(false)
        end
      end
    end
    describe '#unverify' do
      context 'when id exists' do
        it 'calls save with `unverify`' do
          user = described_class.new('id' => '1')
          allow(user).to receive(:save)

          user.unverify

          expect(user).to have_received(:save).with('unverify')
        end
      end

      context 'when id is absent' do
        it 'returns false' do
          user = described_class.new
          allow(user).to receive(:save)

          expect(user.unverify).to eq(false)
        end
      end
    end
  end
end
