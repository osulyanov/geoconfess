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
end
