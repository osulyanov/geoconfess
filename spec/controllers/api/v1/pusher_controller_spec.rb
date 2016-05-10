require 'rails_helper'

describe Api::V1::PusherController, type: :controller do
  let(:user) { create :user }
  let(:token) { create :access_token, resource_owner_id: user.id }

  before do
    allow(Pusher).to receive(:authenticate)
      .with("private-#{user.id}", '122125.3471996')
      .and_return(auth: '431f7475e961c95db8f3:12ab411ccef32b15b41cea458f125c91afd344ba5a19e700608669a6f27a598e')
  end

  describe 'POST #auth' do
    context 'without channel_name' do
      before do
        post :auth, format: :json, socket_id: '122125.3471996',
                    access_token: token.token
      end

      it { expect(response).to have_http_status(:forbidden) }

      it { expect(response.body).to be_empty }
    end

    context 'without socket_id' do
      before do
        post :auth, format: :json, channel_name: "private-#{user.id}",
                    access_token: token.token
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }

      it { expect(response.body).to be_empty }
    end

    context 'with wrong channel_name' do
      let(:other_user) { create :user }

      before do
        post :auth, format: :json, channel_name: "private-#{other_user.id}",
                    access_token: token.token
      end

      it { expect(response).to have_http_status(:forbidden) }

      it { expect(response.body).to be_empty }
    end

    context 'with correct channel_name and socket_id' do
      before do
        post :auth, format: :json, channel_name: "private-#{user.id}",
                    socket_id: '122125.3471996', access_token: token.token
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns auth as JSON' do
        result = json['auth']

        expect(result).to be_present
      end
    end

    context 'with expired access_token' do
      let(:token) do
        create :access_token, resource_owner_id: user.id,
                              expires_in: 0
      end

      before do
        post :auth, format: :json, channel_name: 'private-0',
                    socket_id: '122125.3471996', access_token: token.token
      end

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end
end
