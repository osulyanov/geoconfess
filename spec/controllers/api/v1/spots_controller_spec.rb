require 'rails_helper'

RSpec.describe Api::V1::SpotsController, type: :controller do

  let(:parish) { create :parish }
  let(:priest) { create :user, role: :priest, parish: parish }
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:church) { create :church }
  let!(:spot) { create :spot, church: church, priest: priest }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :index, format: :json, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns spots as json' do
      ids = json.map { |r| r['id'] }
      expect(ids).to contain_exactly(spot.id)
    end
  end

  describe 'GET #index, me=true' do
    let(:token) { create :access_token, resource_owner_id: priest.id }
    let(:other_priest) { create :user, role: :priest, parish: parish }
    let!(:other_spot) { create :spot, church: church, priest: other_priest }

    before do
      get :index, format: :json, me: true, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns spots of current priest as json' do
      ids = json.map { |r| r['id'] }
      expect(ids).to contain_exactly(spot.id)
    end
  end


  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: user.id }
    before do
      get :show, format: :json, id: spot.id, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns spot as json' do
      expect(json['id']).to eq(spot.id)
    end
  end


  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      post :create, format: :json, access_token: token.token,
           spot: { name: 'New spot', church_id: church.id }
    end

    it { expect(response).to have_http_status(:success) }

    it 'creates spot' do
      last_spot = priest.spots.last
      expect(last_spot.name).to eq('New spot')
    end

    context 'user with role user' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'PUT #update' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      put :update, format: :json, access_token: token.token, id: spot.id,
          spot: { name: 'Updated spot' }
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates spot data' do
      spot.reload
      expect(spot.name).to eq('Updated spot')
    end

    context 'user with role user' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'DELETE #destroy' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      delete :destroy, format: :json, access_token: token.token, id: spot.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys spot' do
      expect(Spot.all).not_to include(spot)
    end

    context 'user cannot destroy spot' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'doesn\'t destroy the spot' do
        spot.reload
        expect(spot).to be_persisted
      end
    end
  end

end
