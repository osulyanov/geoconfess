require 'rails_helper'

describe Api::V1::UsersController, type: :controller do

  describe 'GET #show' do
    let(:admin) { create :user, :admin }
    let(:token) { create :access_token, resource_owner_id: admin.id }
    let(:user) { create :user }

    before do
      get :show, format: :json, id: user.id, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns current user as json' do
      result = json['id']

      expect(result).to eq(user.id)
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: admin.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'PUT #update' do
    let(:admin) { create :user, :admin }
    let(:token) { create :access_token, resource_owner_id: admin.id }
    subject { create :user }

    before do
      put :update, format: :json, access_token: token.token, id: subject.id,
          user: { name: 'UpdatedName' }
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates user\'s data' do
      subject.reload
      expect(subject.name).to eq('UpdatedName')
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: admin.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'DELETE #destroy' do
    let(:admin) { create :user, :admin }
    let(:token) { create :access_token, resource_owner_id: admin.id }
    let(:user) { create :user, active: false }

    before do
      delete :destroy, format: :json, access_token: token.token, id: user.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys user' do
      result = assigns(:user)

      expect(result).to be_destroyed
    end

    context 'user cannot destroy themselves' do
      let (:token) { create :access_token, resource_owner_id: user.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t destroy the user' do
        user.reload

        result = user

        expect(result).to be_persisted
      end
    end
  end

  describe 'PUT #activate' do
    let(:admin) { create :user, :admin }
    let(:token) { create :access_token, resource_owner_id: admin.id }
    subject { create :user, active: false }

    before do
      put :activate, format: :json, access_token: token.token, id: subject.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates user\'s data' do
      subject.reload

      expect(subject).to be_active
    end

    context 'user cannot activate themselves' do
      let (:token) { create :access_token, resource_owner_id: subject.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t update the user' do
        subject.reload

        expect(subject).not_to be_active
      end
    end
  end

  describe 'PUT #deactivate' do
    let(:admin) { create :user, :admin }
    let(:token) { create :access_token, resource_owner_id: admin.id }
    subject { create :user, active: true }

    before do
      put :deactivate, format: :json, access_token: token.token, id: subject.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates user\'s data' do
      subject.reload

      expect(subject).not_to be_active
    end

    context 'user cannot deactivate themselves' do
      let (:token) { create :access_token, resource_owner_id: subject.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t update the user' do
        subject.reload

        expect(subject).to be_active
      end
    end
  end
end
