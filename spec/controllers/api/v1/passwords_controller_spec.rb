require 'rails_helper'

describe Api::V1::PasswordsController, type: :controller do
  describe 'POST #create' do
    let!(:user) { create :user }

    context 'with email of existing user' do
      it 'returns http success' do
        post :create, user: { email: user.email }
        expect(response).to have_http_status(:success)
      end

      it 'sends an email' do
        expect do
          post :create, user: { email: user.email }
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'with wrong email' do
      it 'returns not found' do
        post :create, user: { email: 'wrong@mail.ru' }
        expect(response).to have_http_status(:not_found)
      end

      it 'does\'n send an email' do
        expect do
          post :create, user: { email: 'wrong@mail.ru' }
        end.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
