require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :controller do
  describe 'POST create' do
    context 'with correct user data' do
      before do
        post :create, user: attributes_for(:user, name: 'Newbie')
      end

      it { expect(response).to have_http_status(:created) }

      it 'creates a new entry' do
        expect(User.last.name).to eq('Newbie')
      end

      it 'new user is inactive' do
        expect(User.last).not_to be_active
      end
    end
  end
end
