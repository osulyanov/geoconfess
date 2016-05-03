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
      result = described_class.active

      expect(result).to include(active_spot)
    end

    it 'doesn\'t return spots with inactive priests' do
      result = described_class.active

      expect(result).not_to include(inactive_spot)
    end
  end

  describe '.now' do
    context 'dynamic' do
      it 'returns spot updated less than 15 minutes ago' do
        spot = create(:spot, activity_type: :dynamic, priest: priest,
                             updated_at: 10.minutes.ago)

        result = described_class.now

        expect(result).to include(spot)
      end

      it 'doesn\'t return spot updated more than 15 minutes ago' do
        spot = create(:spot, activity_type: :dynamic, priest: priest,
                             updated_at: 20.minutes.ago)

        result = described_class.now

        expect(result).not_to include(spot)
      end
    end

    context 'static' do
      it 'returns spot with active right now recurrence' do
        spot = create(:spot, activity_type: :static, priest: priest)
        create(:recurrence, spot: spot, date: Time.zone.today,
                            start_at: '00:00', stop_at: '23:59')

        result = described_class.now

        expect(result).to include(spot)
      end

      it 'doesn\'t return spot without active right now recurrence' do
        spot = create(:spot, activity_type: :static, priest: priest)
        create(:recurrence, spot: spot, date: 1.day.from_now,
                            start_at: '00:00', stop_at: '23:59')

        result = described_class.now

        expect(result).not_to include(spot)
      end
    end
  end

  describe '.of_priest' do
    let(:other_priest) { create :user, role: :priest }
    let!(:other_spot) { create(:spot, priest: other_priest) }
    let!(:spot) { create(:spot, priest: priest) }

    it 'returns spots with certain priest_id' do
      spot = create(:spot, activity_type: :dynamic, priest: priest)

      result = described_class.of_priest(priest.id)

      expect(result).to include(spot)
    end

    it 'does\'n return spots with other priest_id' do
      spot = create(:spot, activity_type: :dynamic, priest: priest)

      result = described_class.of_priest(priest.id)

      expect(result).not_to include(other_spot)
    end
  end

  describe '.of_type' do
    let!(:dynamic_spot) { create(:spot, priest: priest, activity_type: :dynamic) }
    let!(:static_spot) { create(:spot, priest: priest, activity_type: :static) }

    it 'returns spots of certain type' do
      result = described_class.of_type(:static)

      expect(result).to include(static_spot)
    end

    it 'does\'n return spots of other types' do
      result = described_class.of_type(:static)

      expect(result).not_to include(dynamic_spot)
    end
  end

  describe '.nearest' do
    let!(:spot_in_5km) do
      create(:spot, priest: priest, latitude: 55.35223644610148, longitude: 85.99620691142812)
    end
    let!(:spot_in_20km) do
      create(:spot, priest: priest, latitude: 55.21905341631711, longitude: 85.87318871934184)
    end
    let!(:spot_in_15km) do
      create(:spot, priest: priest, latitude: 55.487328778339084, longitude: 86.02263019255177)
    end

    it 'returns spots in certain radius' do
      result = described_class.nearest(55.3585288, 86.0740275, 10)

      expect(result).to include(spot_in_5km)
    end

    it 'does\'n return spots outside the circle' do
      result = described_class.nearest(55.3585288, 86.0740275, 10)

      expect(result).not_to include(spot_in_20km)
    end

    it 'sorts spots by distance' do
      result = described_class.nearest(55.3585288, 86.0740275, 30)

      expect(result).to eq([spot_in_5km, spot_in_15km, spot_in_20km])
    end
  end

  describe '.outdated' do
    let!(:dynamic_spot_10min) do
      create(:spot, priest: priest, activity_type: :dynamic, updated_at: 10.minutes.ago)
    end
    let!(:dynamic_spot_20min) do
      create(:spot, priest: priest, activity_type: :dynamic, updated_at: 20.minutes.ago)
    end
    let!(:static_spot_10min) do
      create(:spot, priest: priest, activity_type: :static, updated_at: 10.minutes.ago)
    end

    it 'returns dynamic spots created more than 15 minutes ago' do
      result = described_class.outdated

      expect(result).to include(dynamic_spot_20min)
    end

    it 'does\'n return dynamic spots created less than 15 minutes ago' do
      result = described_class.outdated

      expect(result).not_to include(dynamic_spot_10min)
    end

    it 'does\'n return static spots' do
      result = described_class.outdated

      expect(result).not_to include(static_spot_10min)
    end
  end

  describe '.assign_or_new' do
    context 'if dynamic spot for the priest already exists' do
      let!(:spot) { create(:spot, activity_type: :dynamic, priest: priest, latitude: 11.01, longitude: 22.01) }
      let!(:static_spot) { create(:spot, activity_type: :static, priest: priest) }
      let(:other_priest) { create :user, role: :priest }
      let!(:other_spot) { create(:spot, activity_type: :dynamic, priest: other_priest) }
      let(:spot_attrs) { { activity_type: :dynamic, latitude: 11.02, longitude: 22.02 } }

      it 'returns existing dynamic spot of current user' do
        result = priest.spots.assign_or_new(spot_attrs).id

        expect(result).to eq(spot.id)
      end

      it 'updates coordinates' do
        result = priest.spots.assign_or_new(spot_attrs)

        expect(result.latitude).to eq(spot_attrs[:latitude])
        expect(result.longitude).to eq(spot_attrs[:longitude])
      end
    end

    context 'if dynamic spot for the priest doesn\'t exist' do
      let!(:static_spot) { create(:spot, activity_type: :static, priest: priest) }
      let(:other_priest) { create :user, role: :priest }
      let!(:other_spot) { create(:spot, activity_type: :dynamic, priest: other_priest) }
      let(:spot_attrs) { { activity_type: :dynamic, latitude: 11.02, longitude: 22.02 } }

      it 'creates a new one' do
        result = priest.spots.assign_or_new(spot_attrs)

        expect(result).to be_a_new(Spot)
      end

      it 'sets priest' do
        result = priest.spots.assign_or_new(spot_attrs)

        expect(result.priest_id).to eq(priest.id)
      end

      it 'sets type dynamic' do
        result = priest.spots.assign_or_new(spot_attrs)

        expect(result).to be_dynamic
      end

      it 'sets coordinates' do
        result = priest.spots.assign_or_new(spot_attrs)

        expect(result.latitude).to eq(spot_attrs[:latitude])
        expect(result.longitude).to eq(spot_attrs[:longitude])
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
