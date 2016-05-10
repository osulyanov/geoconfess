require 'rails_helper'

describe Api::V1::SpotsController, type: :controller do
  let(:priest) { create :user, role: :priest }
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let!(:spot) do
    create :spot, priest: priest, activity_type: :static,
                  latitude: 35.487, longitude: 96.022
  end

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
        create(:spot, priest: another_priest)

        get :index, priest_id: other_priest.id, format: :json,
            access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(other_spot_1.id, other_spot_2.id)
      end
    end

    context 'filter by now' do
      it 'returns only active right now spots' do
        active_spot = create(:spot, activity_type: :dynamic, priest: priest,
                                    updated_at: 10.minutes.ago)
        create(:spot, activity_type: :dynamic, priest: priest,
                      updated_at: 20.minutes.ago)

        get :index, now: true, format: :json, access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(active_spot.id)
      end
    end

    context 'filter by type' do
      let!(:dynamic_spot) do
        create(:spot, priest: priest,
                      activity_type: :dynamic)
      end

      it 'returns only static spots if type=static' do
        get :index, type: :static, format: :json, access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(spot.id)
      end

      it 'returns only dynamic spots if type=dynamic' do
        get :index, type: :dynamic, format: :json, access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(dynamic_spot.id)
      end
    end

    context 'filter by distance' do
      let!(:spot_in_5km) do
        create(:spot, priest: priest, latitude: 55.35223644610148,
               longitude: 85.99620691142812)
      end
      let!(:spot_in_15km) do
        create(:spot, priest: priest, latitude: 55.487328778339084,
               longitude: 86.02263019255177)
      end

      it 'returns all spots if latitude doesn\'t defined' do
        get :index, lng: 86.0740275, distance: 10, format: :json,
            access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result)
          .to contain_exactly(spot.id, spot_in_5km.id, spot_in_15km.id)
      end

      it 'returns all spots if longitude doesn\'t defined' do
        get :index, lat: 55.3585288, distance: 10, format: :json,
            access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result)
          .to contain_exactly(spot.id, spot_in_5km.id, spot_in_15km.id)
      end

      it 'returns all spots if distance doesn\'t defined' do
        get :index, lat: 55.3585288, lng: 86.0740275, format: :json,
            access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result)
          .to contain_exactly(spot.id, spot_in_5km.id, spot_in_15km.id)
      end

      it 'returns only spots in defined radius if latitude, longitude and
                                                        distance are defined' do
        get :index, lat: 55.3585288, lng: 86.0740275, distance: 10,
            format: :json, access_token: token.token

        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(spot_in_5km.id)
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
      let(:token) { create :access_token, resource_owner_id: user.id }

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
      let(:token) { create :access_token, resource_owner_id: user.id }

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
      let(:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'doesn\'t destroy the spot' do
        spot.reload

        result = spot

        expect(result).to be_persisted
      end
    end
  end
end
