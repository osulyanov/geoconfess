require 'rails_helper'

describe Api::V1::RecurrencesController, type: :controller do
  let(:priest) { create :user, role: :priest }
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:spot) { create :spot, priest: priest }
  let!(:recurrence) { create :recurrence, spot: spot }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :index, format: :json, access_token: token.token, id: spot.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns recurrence as json' do
      result = json.map { |r| r['id'] }

      expect(result).to contain_exactly(recurrence.id)
    end
  end

  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :show, format: :json, id: recurrence.id, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns recurrence as json' do
      result = json['id']

      expect(result).to eq(recurrence.id)
    end
  end

  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      post :create, id: spot.id, spot_id: spot.id, format: :json,
           access_token: token.token, recurrence: recurrence_params
    end

    context 'with date' do
      let(:recurrence_params) do
        { date: '2016-01-07', start_at: '10:15',
                                  stop_at: '16:00' }
      end

      it { expect(response).to have_http_status(:success) }

      it 'creates recurrence' do
        last_recurrence = spot.recurrences.last

        result = last_recurrence.date

        expect(result).to eq(Date.parse('2016-01-07'))
      end
    end

    context 'with weekdays' do
      let(:recurrence_params) do
        { week_days: %w(Tuesday Thursday),
          start_at: '10:15', stop_at: '16:00' }
      end

      it { expect(response).to have_http_status(:success) }

      it 'creates recurrence' do
        last_recurrence = spot.recurrences.last

        result = last_recurrence.week_days

        expect(result).to contain_exactly('Tuesday', 'Thursday')
      end
    end

    context 'user with role user' do
      let(:recurrence_params) do
        { date: '2016-01-07', start_at: '10:15', stop_at: '16:00' }
      end

      let(:token) { create :access_token, resource_owner_id: user.id }

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

      result = recurrence.date

      expect(result).to eq(Date.parse('2017-06-18'))
    end

    context 'user with role user' do
      let(:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'DELETE #destroy' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      delete :destroy, format: :json, access_token: token.token,
             id: recurrence.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys recurrence' do
      result = Recurrence.all

      expect(result).not_to include(recurrence)
    end

    context 'user cannot destroy recurrence' do
      let(:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'doesn\'t destroy the recurrence' do
        recurrence.reload

        result = recurrence

        expect(result).to be_persisted
      end
    end
  end

  describe 'GET #for_priest' do
    let(:other_priest) { create :user, role: :priest }
    let(:other_spot) { create :spot, priest: other_priest, name: 'Other one' }
    let!(:other_recurrence) { create :recurrence, spot: other_spot }
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :for_priest, format: :json, access_token: token.token,
          priest_id: priest.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns only recurrences of passed priest' do
      result = json.map { |r| r['name'] }

      expect(result).to contain_exactly(recurrence.spot.name)
    end
  end

  describe 'PUT #confirm_availability' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      put :confirm_availability, format: :json, access_token: token.token,
                                 id: recurrence.id
      recurrence.reload
    end

    it { expect(response).to have_http_status(:success) }

    it 'set active_date to current date' do
      result = recurrence.active_date

      expect(result).to eq(Time.zone.today)
    end

    it 'reset busy_count' do
      result = recurrence.busy_count

      expect(result).to eq(0)
    end
  end
end
