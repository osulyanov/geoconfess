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
end
