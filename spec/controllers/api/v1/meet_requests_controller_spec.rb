require 'rails_helper'

describe Api::V1::MeetRequestsController, type: :controller do

  let(:priest) { create :user, role: :priest }
  let(:user) { create :user }
  let(:other_user) { create :user }
  let!(:request_1) { create :request, priest: priest, penitent: user }
  let!(:request_2) { create :request, priest: priest, penitent: other_user }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    context 'basic functions' do

      before do
        get :index, format: :json, access_token: token.token
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns requests if current user as json' do
        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(request_1.id)
      end

      context 'with expired access_token' do
        let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }

        it { expect(response).to have_http_status(:unauthorized) }

        it { expect(response.body).to be_empty }
      end
    end

    context 'filter by priest' do
      let(:other_priest) { create :user, role: :priest }
      let!(:request_to_other_priest) do
        create :request, priest: other_priest, penitent: user
      end

      before do
        get :index, format: :json, access_token: token.token,
            party_id: other_priest.id
      end

      it 'returns request to certain priest' do
        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(request_to_other_priest.id)
      end
    end
  end


  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    context 'with ID of user\'s request' do

      before do
        get :show, format: :json, id: request_1.id, access_token: token.token
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns current user as json' do
        result = json['id']

        expect(result).to eq(request_1.id)
      end
    end

    context 'with ID of other_user\'s request' do

      before do
        get :show, format: :json, id: request_2.id, access_token: token.token
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end


  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      MeetRequest.destroy_all
      post :create, format: :json, access_token: token.token,
           request: attributes_for(:request, priest_id: priest.id, status: 'accepted')
    end

    it { expect(response).to have_http_status(:success) }

    it 'creates request' do
      result = MeetRequest.last.penitent_id

      expect(result).to eq(user.id)
    end

    it 'status is pending' do
      result = MeetRequest.last

      expect(result).to be_pending
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'PUT #update' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      put :update, format: :json, access_token: token.token, id: request_1.id,
          request: { status: 'accepted' }
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates request data' do
      result = request_1.reload

      expect(result).to be_accepted
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: user.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'DELETE #destroy' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      delete :destroy, format: :json, access_token: token.token, id: request_1.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys request' do
      result = MeetRequest.all

      expect(result).not_to include(request_1)
    end

    context 'penitent cannot destroy request' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t destroy the request' do
        result = request_1.reload

        expect(result).to be_persisted
      end
    end
  end

  describe 'PUT #accept' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      put :accept, format: :json, access_token: token.token, id: request_1.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates request data' do
      result = request_1.reload

      expect(result).to be_accepted
    end

    context 'penitent cannot accept request' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t update the request' do
        result = request_1.reload

        expect(result).not_to be_accepted
      end
    end
  end


  describe 'PUT #refuse' do
    let(:token) { create :access_token, resource_owner_id: priest.id }

    before do
      put :refuse, format: :json, access_token: token.token, id: request_1.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates request data' do
      result = request_1.reload

      expect(result).to be_refused
    end

    context 'penitent cannot refuse request' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t update the request' do
        result = request_1.reload

        expect(result).not_to be_refused
      end
    end
  end

end
