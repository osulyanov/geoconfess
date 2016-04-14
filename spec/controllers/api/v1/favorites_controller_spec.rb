require 'rails_helper'

RSpec.describe Api::V1::FavoritesController, type: :controller do
  let(:priest) { create :user, role: :priest }
  let(:user) { create :user }
  let!(:favorite) { create :favorite, priest: priest, user: user }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :index, format: :json, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns favorites if current user as json' do
      ids = json.map { |r| r['id'] }
      expect(ids).to contain_exactly(favorite.id)
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      post :create, format: :json, access_token: token.token,
           favorite: { priest_id: priest.id }
    end

    it { expect(response).to have_http_status(:success) }

    it 'creates favorite' do
      last_favorite = Favorite.last
      expect(last_favorite.user_id).to eq(user.id)
    end

    it 'with priest' do
      last_favorite = Favorite.last
      expect(last_favorite.priest_id).to eq(priest.id)
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'DELETE #destroy' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      delete :destroy, format: :json, access_token: token.token, id: favorite.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys favorite' do
      expect(Favorite.all).not_to include(favorite)
    end

    context 'priest cannot destroy favorite' do
      let (:token) { create :access_token, resource_owner_id: priest.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t destroy the favorite' do
        favorite.reload
        expect(favorite).to be_persisted
      end
    end
  end
end
