require 'rails_helper'

RSpec.describe Spot, type: :model do
  let(:priest) { create :user, role: :priest }
  subject { build(:spot, priest: priest) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without priest' do
    subject.priest = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without name' do
    subject.name = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without latitude' do
    subject.latitude = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without longitude' do
    subject.longitude = nil
    expect(subject).not_to be_valid
  end

  it 'not valid with wrang activity_type' do
    expect { subject.activity_type = 3 }.to raise_error(ArgumentError, "'3' is not a valid activity_type")
  end

  describe '.active' do
    let(:active_priest) { create :user, role: :priest }
    let!(:active_spot) { create(:spot, priest: active_priest) }
    let(:inactive_priest) { create :user, role: :priest, active: false }
    let!(:inactive_spot) { create(:spot, priest: inactive_priest) }

    it 'returns spots with active priests' do
      result = Spot.active

      expect(result).to include(active_spot)
    end

    it 'doesn\'t return spots with inactive priests' do
      result = Spot.active

      expect(result).not_to include(inactive_spot)
    end
  end

  describe '.now' do
    context 'dynamic' do
      it 'returns spot updated less than 15 minutes ago' do
        spot = create(:spot, activity_type: :dynamic, priest: priest,
                      updated_at: 10.minutes.ago)

        result = Spot.now

        expect(result).to include(spot)
      end

      it 'doesn\'t return spot updated more than 15 minutes ago' do
        spot = create(:spot, activity_type: :dynamic, priest: priest,
                      updated_at: 20.minutes.ago)

        result = Spot.now

        expect(result).not_to include(spot)
      end
    end

    context 'static' do
      it 'returns spot with active right now recurrence' do
        spot = create(:spot, activity_type: :static, priest: priest)
        create(:recurrence, spot: spot, date: Time.zone.today,
               start_at: '00:00', stop_at: '23:59')

        result = Spot.now

        expect(result).to include(spot)
      end

      it 'doesn\'t return spot without active right now recurrence' do
        spot = create(:spot, activity_type: :static, priest: priest)
        create(:recurrence, spot: spot, date: 1.day.from_now,
               start_at: '00:00', stop_at: '23:59')

        result = Spot.now

        expect(result).not_to include(spot)
      end
    end
  end
end

# == Schema Information
#
# Table name: spots
#
#  id            :integer          not null, primary key
#  name          :string
#  priest_id     :integer
#  church_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  activity_type :integer          default(0), not null
#  latitude      :float
#  longitude     :float
#  street        :string
#  postcode      :string
#  city          :string
#  state         :string
#  country       :string
#
# Indexes
#
#  index_spots_on_church_id  (church_id)
#  index_spots_on_priest_id  (priest_id)
#
