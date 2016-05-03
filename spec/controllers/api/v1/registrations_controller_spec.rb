require 'rails_helper'

describe Api::V1::RegistrationsController, type: :controller do
  describe 'POST create' do
    context 'with correct user data' do
      let(:user_data) { attributes_for(:user, name: 'Newbie') }

      before do
        post :create, user: user_data
      end

      it { expect(response).to have_http_status(:created) }

      it 'creates a new entry' do
        result = User.last.name

        expect(result).to eq('Newbie')
      end

      it 'new user is active' do
        result = User.last

        expect(result).to be_active
      end

      context 'priest' do
        let(:user_data) do
          attributes_for(:user, role: :priest)
        end

        it { expect(response).to have_http_status(:created) }

        it 'new priest user is inactive' do
          result = User.last

          expect(result).not_to be_active
        end
      end
    end
  end
end
