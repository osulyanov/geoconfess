require 'rails_helper'

describe 'OAuth authorization', type: :request do
  let(:user) { create(:user, os: nil, push_token: nil) }
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

    it 'updates user\'s os and push token' do
      client.password.get_token(user.email, user.password,
                                os: 'android', push_token: '123456')
      user.reload
      expect(user.os).to eq('android')
    end

    it 'updates user\'s push token' do
      client.password.get_token(user.email, user.password,
                                os: 'android', push_token: '123456')
      user.reload
      expect(user.push_token).to eq('123456')
    end
  end

  context 'if credentials incorrect' do
    it 'auth nok' do
      expect do
        client.password.get_token(user.email, 'wrong password')
      end.to raise_error(OAuth2::Error)
    end
  end
end
