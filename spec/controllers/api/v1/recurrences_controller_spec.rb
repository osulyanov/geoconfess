require 'rails_helper'

RSpec.describe Api::V1::RecurrencesController, type: :controller do

  let(:parish) { create :parish }
  let(:priest) { create :user, role: :priest, parish: parish }
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:church) { create :church }
  let(:spot) { create :spot, church: church, priest: priest }
  let!(:recurrence) { create :recurrence, spot: spot }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :index, format: :json, access_token: token.token, id: spot.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns recurrence as json' do
      ids = json.map { |r| r['id'] }
      expect(ids).to contain_exactly(recurrence.id)
    end
  end


  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: user.id }
    before do
      get :show, format: :json, id: recurrence.id, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns recurrence as json' do
      expect(json['id']).to eq(recurrence.id)
    end
  end


  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      post :create, id: spot.id, spot_id: spot.id, format: :json, access_token: token.token,
           recurrence: recurrence_params
    end

    context 'with date' do
      let(:recurrence_params) { { date: '2016-01-07', start_at: '10:15', stop_at: '16:00' } }

      it { expect(response).to have_http_status(:success) }

      it 'creates recurrence' do
        last_recurrence = spot.recurrences.last
        expect(last_recurrence.date).to eq(Date.parse '2016-01-07')
      end
    end

    context 'with weekdays' do
      let(:recurrence_params) { { week_days: ['Tuesday', 'Thursday'], start_at: '10:15', stop_at: '16:00' } }

      it { expect(response).to have_http_status(:success) }

      it 'creates recurrence' do
        last_recurrence = spot.recurrences.last
        expect(last_recurrence.week_days).to contain_exactly('Tuesday', 'Thursday')
      end
    end

    context 'user with role user' do
      let(:recurrence_params) { { date: '2016-01-07', start_at: '10:15', stop_at: '16:00' } }

      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'PUT #update' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      put :update, format: :json, access_token: token.token, id: recurrence.id,
          recurrence: { date: '2017-06-18' }
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates recurrence data' do
      recurrence.reload
      expect(recurrence.date).to eq(Date.parse '2017-06-18')
    end

    context 'user with role user' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'DELETE #destroy' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      delete :destroy, format: :json, access_token: token.token, id: recurrence.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys recurrence' do
      expect(Recurrence.all).not_to include(recurrence)
    end

    context 'user cannot destroy recurrence' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'doesn\'t destroy the recurrence' do
        recurrence.reload
        expect(recurrence).to be_persisted
      end
    end
  end

  describe 'GET #for_priest' do
    let(:other_priest) { create :user, role: :priest, parish: (create :parish) }
    let(:other_spot) { create :spot, church: (create :church), priest: other_priest, name: 'Other one' }
    let!(:other_recurrence) { create :recurrence, spot: other_spot }
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :for_priest, format: :json, access_token: token.token, priest_id: priest.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns only recurrences of passed priest' do
      names = json.map { |r| r['name'] }
      expect(names).to contain_exactly(recurrence.spot.name)
    end

  end

end
