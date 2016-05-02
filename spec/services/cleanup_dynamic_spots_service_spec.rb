require 'rails_helper'

describe CleanupDynamicSpotsService do

  let(:priest) { create(:user, role: :priest) }
  let!(:actual_spot) do
    create(:spot, priest: priest, activity_type: :dynamic,
           updated_at: 9.minutes.ago)
  end
  let!(:outdated_spot) do
    create(:spot, priest: priest, activity_type: :dynamic,
           updated_at: 19.minutes.ago)
  end

  subject { described_class.new }

  describe '#spots_to_remove' do
    it 'returns outdated spots' do
      result = subject.spots_to_remove

      expect(result).to include(outdated_spot)
    end

    it 'doesn\'t return actual spots' do
      result = subject.spots_to_remove

      expect(result).not_to include(actual_spot)
    end
  end

  describe '#perform' do
    it 'removes outdated spots' do
      subject.perform

      result = Spot.all

      expect(result).not_to include(outdated_spot)
    end

    it 'doesn\'t remove actual spots' do
      subject.perform

      result = Spot.all

      expect(result).to include(actual_spot)
    end
  end
end
