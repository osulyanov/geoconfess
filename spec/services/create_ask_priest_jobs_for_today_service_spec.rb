require 'rails_helper'

describe CreateAskPriestJobsForTodayService do

  let(:priest) { create(:user, role: :priest) }
  let(:spot) { create(:spot, priest: priest) }
  let!(:today_recurrence) { create(:recurrence, spot: spot, date: Time.zone.today,
                                   start_at: '14:00', stop_at: '15:00') }
  let!(:tomorrow_recurrence) { create(:recurrence, spot: spot, date: 1.day.from_now,
                                      start_at: '14:00', stop_at: '15:00') }

  subject { CreateAskPriestJobsForTodayService.new }

  describe '#todays_recurrences' do
    it 'returns recurrences which happens today' do
      result = subject.todays_recurrences

      expect(result).to include(today_recurrence)
    end

    it 'doesn\'t return recurrences of other days' do
      result = subject.todays_recurrences

      expect(result).not_to include(tomorrow_recurrence)
    end
  end
end
