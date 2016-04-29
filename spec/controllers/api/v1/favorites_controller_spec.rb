require 'rails_helper'

describe Api::V1::FavoritesController, type: :controller do
  let(:priest) { create :user, role: :priest }
  let(:user) { create :user }
  let(:other_user) { create :user }
  let!(:other_favorite) { create :favorite, priest: priest, user: other_user }

  describe 'GET #index' do
    let!(:favorite) { create :favorite, priest: priest, user: user }
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :index, format: :json, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns favorites if current user as json' do
      result = json.map { |r| r['id'] }

      expect(result).to contain_exactly(favorite.id)
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    context 'priest already in favorites of this user' do
      let!(:favorite) { create :favorite, priest: priest, user: user }

      before do
        post :create, format: :json, access_token: token.token,
             favorite: { priest_id: priest.id }
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns already created favorite' do
        result = json['id']

        expect(result).to eq(favorite.id)
      end

      it 'with priest' do
        result = json['priest']['id']

        expect(result).to eq(priest.id)
      end
    end

    context 'priest not in the favorites yet' do
      before do
        post :create, format: :json, access_token: token.token,
             favorite: { priest_id: priest.id }
      end

      it { expect(response).to have_http_status(:success) }

      it 'creates favorite' do
        result = Favorite.last.user_id

        expect(result).to eq(user.id)
      end

      it 'with priest' do
        result = Favorite.last.priest_id

        expect(result).to eq(priest.id)
      end
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }
      
      before do
        post :create, format: :json, access_token: token.token,
             favorite: { priest_id: priest.id }
      end

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'DELETE #destroy' do
    let!(:favorite) { create :favorite, priest: priest, user: user }
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      delete :destroy, format: :json, access_token: token.token, id: favorite.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys favorite' do
      result = Favorite.all

      expect(result).not_to include(favorite)
    end

    context 'priest cannot destroy favorite' do
      let (:token) { create :access_token, resource_owner_id: priest.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t destroy the favorite' do
        favorite.reload

        result = favorite

        expect(result).to be_persisted
      end
    end
  end
end
