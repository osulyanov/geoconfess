require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :controller do
  describe 'POST create' do
    before do
      post :create, user: attributes_for(:user, name: 'Newbie')
    end

    it { expect(response).to have_http_status(:created) }

    it 'creates a new entry' do
      expect(User.last.name).to eq('Newbie')
    end

    it 'new user is inactive' do
      expect(User.last.active?).to be false
    end
  end
end
