require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :controller do
  describe 'POST create' do
    context 'with correct user data' do
      let(:user_data) { attributes_for(:user, name: 'Newbie') }
      before do
        post :create, user: user_data
      end

      it { expect(response).to have_http_status(:created) }

      it 'creates a new entry' do
        expect(User.last.name).to eq('Newbie')
      end

      it 'new user is active' do
        expect(User.last).to be_active
      end

      context 'priest' do
        let(:user_data) do
          attributes_for(:user, role: :priest)
        end

        it { expect(response).to have_http_status(:created) }

        it 'new priest user is inactive' do
          expect(User.last).not_to be_active
        end
      end
    end
  end
end
