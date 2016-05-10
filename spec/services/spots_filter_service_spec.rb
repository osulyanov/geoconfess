require 'rails_helper'

describe SpotsFilterService do
  describe '#results' do
    context 'without filters' do
      it 'returns all active spots' do
        inactive_priest = create(:user, role: :priest, active: false)
        active_priest = create(:user, role: :priest)
        inactive_spot = create(:spot, priest: inactive_priest)
        active_spot = create(:spot, priest: active_priest)
        params = {}

        result = described_class.new(params, active_priest).results

        expect(result).to include(active_spot)
        expect(result).not_to include(inactive_spot)
      end
    end
  end

  context 'filter by priest_id' do
    it 'return only spots of certain priest' do
      other_priest = create(:user, role: :priest)
      other_spot_1 = create(:spot, priest: other_priest)
      other_spot_2 = create(:spot, priest: other_priest)
      another_priest = create(:user, role: :priest)
      create(:spot, priest: another_priest)
      params = { priest_id: other_priest.id }

      result = described_class.new(params, nil).results

      expect(result).to contain_exactly(other_spot_1, other_spot_2)
    end
  end

  context 'filter by now' do
    it 'returns only active right now spots' do
      priest = create(:user, role: :priest)
      active_spot = create(:spot, activity_type: :dynamic, priest: priest,
                                  updated_at: 10.minutes.ago)
      create(:spot, activity_type: :dynamic, priest: priest,
                    updated_at: 20.minutes.ago)
      params = { now: true }

      result = described_class.new(params, nil).results

      expect(result).to contain_exactly(active_spot)
    end
  end

  context 'filter by type' do
    it 'returns only static spots if type=static' do
      priest = create(:user, role: :priest)
      spot = create(:spot, priest: priest, activity_type: :static,
                           latitude: 35.487, longitude: 96.022)
      create(:spot, priest: priest, activity_type: :dynamic)
      params = { type: :static }

      result = described_class.new(params, nil).results

      expect(result).to contain_exactly(spot)
    end

    it 'returns only dynamic spots if type=dynamic' do
      priest = create(:user, role: :priest)
      create(:spot, priest: priest, activity_type: :static,
                    latitude: 35.487, longitude: 96.022)
      dynamic_spot = create(:spot, priest: priest, activity_type: :dynamic)
      params = { type: :dynamic }

      result = described_class.new(params, nil).results

      expect(result).to contain_exactly(dynamic_spot)
    end
  end

  context 'filter by distance' do
    it 'returns all spots if latitude doesn\'t defined' do
      priest = create(:user, role: :priest)
      spot = create(:spot, priest: priest, activity_type: :static,
                           latitude: 35.487, longitude: 96.022)
      spot_in_5km = create(:spot, priest: priest, latitude: 55.35223644610148,
                                  longitude: 85.99620691142812)
      spot_in_15km = create(:spot, priest: priest, latitude: 55.487328778339084,
                                   longitude: 86.02263019255177)
      params = { lng: 86.0740275, distance: 10 }

      result = described_class.new(params, nil).results

      expect(result).to contain_exactly(spot, spot_in_5km, spot_in_15km)
    end

    it 'returns all spots if longitude doesn\'t defined' do
      priest = create(:user, role: :priest)
      spot = create(:spot, priest: priest, activity_type: :static,
                           latitude: 35.487, longitude: 96.022)
      spot_in_5km = create(:spot, priest: priest, latitude: 55.35223644610148,
                                  longitude: 85.99620691142812)
      spot_in_15km = create(:spot, priest: priest, latitude: 55.487328778339084,
                                   longitude: 86.02263019255177)
      params = { lat: 55.3585288, distance: 10 }

      result = described_class.new(params, nil).results

      expect(result).to contain_exactly(spot, spot_in_5km, spot_in_15km)
    end

    it 'returns all spots if distance doesn\'t defined' do
      priest = create(:user, role: :priest)
      spot = create(:spot, priest: priest, activity_type: :static,
                           latitude: 35.487, longitude: 96.022)
      spot_in_5km = create(:spot, priest: priest, latitude: 55.35223644610148,
                                  longitude: 85.99620691142812)
      spot_in_15km = create(:spot, priest: priest, latitude: 55.487328778339084,
                                   longitude: 86.02263019255177)
      params = { lat: 55.3585288, lng: 86.0740275 }

      result = described_class.new(params, nil).results

      expect(result).to contain_exactly(spot, spot_in_5km, spot_in_15km)
    end

    it 'returns only spots in defined radius if latitude, longitude and
        distance are defined' do
      priest = create(:user, role: :priest)
      create(:spot, priest: priest, activity_type: :static,
                    latitude: 35.487, longitude: 96.022)
      spot_in_5km = create(:spot, priest: priest, latitude: 55.35223644610148,
                                  longitude: 85.99620691142812)
      create(:spot, priest: priest, latitude: 55.487328778339084,
                    longitude: 86.02263019255177)
      params = { lat: 55.3585288, lng: 86.0740275, distance: 10 }

      result = described_class.new(params, nil).results

      expect(result).to contain_exactly(spot_in_5km)
    end
  end
end
