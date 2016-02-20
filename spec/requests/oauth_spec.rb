require 'rails_helper'

RSpec.describe 'OAuth authorization', type: :request do
  let(:user) { create(:user) }
  let(:client) do
    OAuth2::Client.new('', '') do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
  end

  context 'if credentials correct' do
    it 'auth ok' do
      token = client.password.get_token(user.email, user.password)
      expect(token).not_to be_expired
    end
  end

  context 'if credentials incorrect' do
    it 'auth nok' do
      expect {
        client.password.get_token(user.email, 'wrong password')
      }.to raise_error(OAuth2::Error)
    end
  end
end
