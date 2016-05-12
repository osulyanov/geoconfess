require 'rails_helper'

describe Api::V1::ChatsController, type: :controller do
  let(:user) { create :user }
  let(:sender) { create :user }
  let(:recipient) { create :user }
  let(:other_sender) { create :user }
  let(:other_recipient) { create :user }
  let!(:message_in_1) do
    create :message, sender: sender, recipient: user,
                               created_at: 1.second.ago
  end
  let!(:message_in_2) do
    create :message, sender: sender, recipient: user,
                               created_at: 5.seconds.ago
  end
  let!(:message_out_1) do
    create :message, sender: user, recipient: recipient,
                                created_at: 4.seconds.ago
  end
  let!(:message_out_2) do
    create :message, sender: user, recipient: recipient,
                                created_at: 3.seconds.ago
  end
  let!(:other_message) do
    create :message, sender: other_sender,
                     recipient: other_recipient
  end

  describe 'GET #index' do
    let(:token) { create :access_token, resource_owner_id: user.id }

    before do
      get :index, format: :json, access_token: token.token
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns chats for current user as json' do
      result = json.map { |r| r['id'] }

      expect(result).to contain_exactly(sender.id, recipient.id)
    end

    context 'with expired access_token' do
      let(:token) do
        create :access_token, resource_owner_id: sender.id,
                              expires_in: 0
      end

      it { expect(response).to have_http_status(:unauthorized) }

      it { expect(response.body).to be_empty }
    end
  end

  describe 'GET #show' do
    let(:token) { create :access_token, resource_owner_id: user.id }
    context 'for current user' do
      before do
        get :show, format: :json, id: recipient.id, access_token: token.token
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns message with certain user as json' do
        result = json.map { |r| r['id'] }

        expect(result).to contain_exactly(message_out_2.id, message_out_1.id)
      end
    end

    context 'for other_user' do
      let(:token) { create :access_token, resource_owner_id: sender.id }

      before do
        get :show, format: :json, id: other_message.id,
            access_token: token.token
      end

      it 'returns empty result' do
        result = json

        expect(result).to eq([])
      end
    end
  end
end
