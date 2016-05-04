require 'rails_helper'

describe Api::V1::MessagesController, type: :controller do
  let(:sender) { create :user }
  let(:recipient) { create :user }
  let(:admin) { create :user, :admin }
  let!(:message) { create :message, sender: sender, recipient: recipient }
  let!(:other_message) { create :message, sender: admin, recipient: recipient }

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: sender.id }

    context 'list of all messages' do
      before do
        get :index, format: :json, access_token: token.token
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns messages for current user as json' do
        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(message.id)
      end
    end

    context 'messages with certain user' do
      let!(:message_to_admin) { create :message, sender: sender, recipient: admin }

      before do
        get :index, interlocutor_id: recipient.id, format: :json, access_token: token.token
      end

      it 'returns only messages with this user' do
        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(message.id)
      end
    end

    context 'with expired access_token' do
      let(:token) { create :access_token, resource_owner_id: sender.id, expires_in: 0 }

      before do
        get :index, format: :json, access_token: token.token
      end

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: recipient.id }

    context 'for current user' do
      before do
        get :show, format: :json, id: message.id, access_token: token.token
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns message as json' do
        expect(json['id']).to eq(message.id)
      end
    end

    context 'for other_user' do
      let(:token) { create :access_token, resource_owner_id: sender.id }

      before do
        get :show, format: :json, id: other_message.id, access_token: token.token
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe 'POST #create' do
    let(:token) { create :access_token, resource_owner_id: sender.id }

    before do
      post :create, format: :json, access_token: token.token,
                    message: { recipient_id: recipient.id, text: 'Test it' }
    end

    it { expect(response).to have_http_status(:success) }

    it 'creates message' do
      last_message = Message.last
      expect(last_message.text).to eq('Test it')
    end

    context 'with expired access_token' do
      let(:token) { create :access_token, resource_owner_id: sender.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'PUT #update' do
    let(:token) { create :access_token, resource_owner_id: sender.id }

    before do
      put :update, format: :json, access_token: token.token, id: message.id,
                   message: { text: 'New text' }
    end

    it { expect(response).to have_http_status(:success) }

    it 'updates message data' do
      message.reload
      expect(message.text).to eq('New text')
    end

    context 'with expired access_token' do
      let(:token) { create :access_token, resource_owner_id: sender.id, expires_in: 0 }

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'DELETE #destroy' do
    let(:token) { create :access_token, resource_owner_id: recipient.id }

    before do
      delete :destroy, format: :json, access_token: token.token, id: other_message.id
    end

    it { expect(response).to have_http_status(:success) }

    it 'destroys sender' do
      expect(Message.all).not_to include(other_message)
    end

    context 'other user cannot destroy message' do
      let(:token) { create :access_token, resource_owner_id: sender.id }

      it { expect(response).to have_http_status(:unauthorized) }

      it 'didn\'t destroy the message' do
        other_message.reload
        expect(other_message).to be_persisted
      end
    end
  end
end
