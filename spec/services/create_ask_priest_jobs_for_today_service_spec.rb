require 'rails_helper'

describe CreateAskPriestJobsForTodayService do

  let(:priest) { create(:user, role: :priest) }
  let(:spot) { create(:spot, priest: priest) }
  let(:wdays) { Date::DAYNAMES - [Time.zone.today.strftime('%A')] }
  let!(:today_recurrence) { create(:recurrence, spot: spot, date: Time.zone.today,
                                   start_at: '14:00', stop_at: '15:00') }
  let!(:recurred_recurrence) { create(:recurrence, spot: spot, date: nil,
                                      start_at: '14:00', stop_at: '15:00',
                                      week_days: wdays) }
  let!(:tomorrow_recurrence) { create(:recurrence, spot: spot, date: 1.day.from_now,
                                      start_at: '14:00', stop_at: '15:00') }

  subject { CreateAskPriestJobsForTodayService.new }

  describe '#todays_recurrences' do
    it 'returns recurrences which happens today' do
      result = subject.todays_recurrences

      expect(result).to include(today_recurrence)
    end

    it 'returns recurred recurrences' do
      result = subject.todays_recurrences

      expect(result).to include(recurred_recurrence)
    end

    it 'doesn\'t return recurrences of other days' do
      result = subject.todays_recurrences

      expect(result).not_to include(tomorrow_recurrence)
    end
  end

  describe '#process_recurrence' do
    context 'recurrence doesn\'t happen today' do
      it 'returns true' do
        result = subject.process_recurrence(recurred_recurrence)

        expect(result).to be true
      end

      it 'doesn\'t call #update_job' do
        allow(recurred_recurrence).to receive(:update_job)

        subject.process_recurrence(recurred_recurrence)

        expect(recurred_recurrence).not_to have_received(:update_job)
      end
    end

    context 'recurrence happens today' do
      it 'calls #update_job' do
        allow(today_recurrence).to receive(:update_job)

        subject.process_recurrence(today_recurrence)

        expect(today_recurrence).to have_received(:update_job)
      end
    end
  end

  describe '#process' do
    it 'calls #process_recurrence for each recurrence' do
      allow(subject).to receive(:process_recurrence)

      subject.process

      expect(subject).to have_received(:process_recurrence).with(today_recurrence)
      expect(subject).to have_received(:process_recurrence).with(recurred_recurrence)
    end
  end
end
