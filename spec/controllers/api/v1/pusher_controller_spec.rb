require 'rails_helper'

describe Api::V1::PusherController, type: :controller do

  let(:user) { create :user }
  let (:token) { create :access_token, resource_owner_id: user.id }

  describe 'POST #auth' do
    context 'without channel_name' do
      before do
        post :auth, format: :json, socket_id: '4cacr23qd423',
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

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }

      before do
        post :auth, format: :json, channel_name: 'private-0',
             socket_id: '4cacr23qd423', access_token: token.token
      end

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end
end
