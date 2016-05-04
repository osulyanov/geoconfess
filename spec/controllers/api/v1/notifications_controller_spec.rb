require 'rails_helper'

describe Api::V1::NotificationsController, type: :controller do
  let(:sender) { create :user }
  let(:recipient) { create :user }
  let (:message) { create(:message, sender: sender, recipient: recipient) }
  let! (:notification) { create(:notification, user: recipient, notificationable: message) }
  let! (:other_notification) { create(:notification, user: sender, notificationable: message) }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: recipient.id }

    before do
      get :index, format: :json, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns notifications of current user as json' do
      ids = json.map { |r| r['id'] }
      expect(ids).to include(notification.id)
    end

    it 'doesn\'t return notifications of other users' do
      ids = json.map { |r| r['id'] }
      expect(ids).not_to include(other_notification.id)
    end

    context 'with expired access_token' do
      let (:token) { create :access_token, resource_owner_id: recipient.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: recipient.id }

    context 'with ID of user\'s notification' do
      before do
        get :show, format: :json, id: notification.id, access_token: token.token
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns current notification as json' do
        expect(json['id']).to eq(notification.id)
      end
    end

    context 'with ID of other_user\'s notification' do
      before do
        get :show, format: :json, id: other_notification.id, access_token: token.token
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'PUT #mark_read' do
    let(:token) { create :access_token, resource_owner_id: recipient.id }

    before do
      put :mark_read, format: :json, access_token: token.token, id: notification.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates notification data' do
      notification.reload
      expect(notification).not_to be_unread
    end

    context 'other users cannot mark notification as read' do
      let (:token) { create :access_token, resource_owner_id: sender.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t update the request' do
        notification.reload
        expect(notification).to be_unread
      end
    end
  end
end
