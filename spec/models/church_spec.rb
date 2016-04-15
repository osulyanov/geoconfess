require 'rails_helper'

RSpec.describe Church, type: :model do
  subject { build(:church) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  context 'after_update' do
    let (:church) { create(:church, latitude: 10.01, longitude: 20.01) }
    let(:priest) { create(:user, role: :priest) }
    let! (:static_spot) { create(:spot, activity_type: Spot.activity_types[:static], church: church, priest: priest) }
    let! (:dynamic_spot) { create(:spot, activity_type: Spot.activity_types[:dynamic], latitude: 11.01, longitude: 22.01, priest: priest) }

    it 'updates static spots coordinates' do
      church.update_attributes latitude: 10.02, longitude: 20.02
      static_spot.reload
      expect(static_spot.latitude).to eq(10.02)
      expect(static_spot.longitude).to eq(20.02)
    end

    it 'doesn\'t update dynamic spots coordinates' do
      church.update_attributes latitude: 10.02, longitude: 20.02
      dynamic_spot.reload
      expect(dynamic_spot.latitude).to eq(11.01)
      expect(dynamic_spot.longitude).to eq(22.01)
    end
  end
end

# == Schema Information
#
# Table name: churches
#
#  id         :integer          not null, primary key
#  name       :string
#  latitude   :float
#  longitude  :float
#  street     :string
#  postcode   :string
#  city       :string
#  state      :string
#  country    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
