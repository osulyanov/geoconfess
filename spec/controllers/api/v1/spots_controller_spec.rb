require 'rails_helper'

describe Api::V1::SpotsController, type: :controller do

  let(:priest) { create :user, role: :priest }
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let!(:spot) { create :spot, priest: priest }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    context 'all results' do
      before do
        get :index, format: :json, access_token: token.token
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns spots as json' do
        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(spot.id)
      end
    end

    context 'filter by priest_id' do
      it 'returns spots as json' do
        other_priest = create(:user, role: :priest)
        other_spot_1 = create(:spot, priest: other_priest)
        other_spot_2 = create(:spot, priest: other_priest)
        another_priest = create(:user, role: :priest)
        another_spot = create(:spot, priest: another_priest)

        get :index, priest_id: other_priest.id, format: :json, access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(other_spot_1.id, other_spot_2.id)
      end
    end
  end

  describe 'GET #index, me=true' do
    let(:token) { create :access_token, resource_owner_id: priest.id }
    let(:other_priest) { create :user, role: :priest }
    let!(:other_spot) { create :spot, priest: other_priest }

    before do
      get :index, format: :json, me: true, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns spots of current priest as json' do
      result = json.map { |r| r['id'] }

      expect(result).to contain_exactly(spot.id)
    end
  end


  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :show, format: :json, id: spot.id, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns spot as json' do
      result = json['id']

      expect(result).to eq(spot.id)
    end
  end


  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      post :create, format: :json, access_token: token.token,
           spot: attributes_for(:spot, name: 'New spot')
    end

    it { expect(response).to have_http_status(:success) }

    it 'creates spot' do
      last_spot = priest.spots.last

      result = last_spot.name

      expect(result).to eq('New spot')
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

      result = spot.name

      expect(result).to eq('Updated spot')
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
      result = Spot.all

      expect(result).not_to include(spot)
    end

    context 'user cannot destroy spot' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'doesn\'t destroy the spot' do
        spot.reload

        result = spot

        expect(result).to be_persisted
      end
    end
  end
end
