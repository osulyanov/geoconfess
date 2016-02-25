require 'rails_helper'

RSpec.describe Api::V1::ChurchesController, type: :controller do

  let(:parish) { create :parish }
  let(:priest) { create :user, role: :priest, parish: parish }
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let!(:church) { create :church }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :index, format: :json, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns churches as json' do
      ids = json.map { |r| r['id'] }
      expect(ids).to contain_exactly(church.id)
    end
  end


  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: user.id }
    before do
      get :show, format: :json, id: church.id, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns current user as json' do
      expect(json['id']).to eq(church.id)
    end
  end


  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      post :create, format: :json, access_token: token.token,
           church: { name: 'New church', latitude: '55.12', longitude: '80.12' }
    end

    it { expect(response).to have_http_status(:success) }

    it 'creates church' do
      last_church = Church.last
      expect(last_church.name).to eq('New church')
    end

    context 'user with role user' do
      let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'PUT #update' do
    let(:token) { create :access_token, resource_owner_id: admin.id }

    before do
      put :update, format: :json, access_token: token.token, id: church.id,
          church: { name: 'Updated church' }
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates church data' do
      church.reload
      expect(church.name).to eq('Updated church')
    end

    context 'user with role priest' do
      let (:token) { create :access_token, resource_owner_id: priest.id }

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'DELETE #destroy' do
    let(:token) { create :access_token, resource_owner_id: admin.id }

    before do
      delete :destroy, format: :json, access_token: token.token, id: church.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys church' do
      expect(Church.all).not_to include(church)
    end

    context 'priest cannot destroy church' do
      let (:token) { create :access_token, resource_owner_id: priest.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'doesn\'t destroy the church' do
        church.reload
        expect(church).to be_persisted
      end
    end
  end

end
