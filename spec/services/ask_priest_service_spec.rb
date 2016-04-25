require 'rails_helper'

describe AskPriestService do

  let(:priest) { create(:user, role: :priest) }
  let(:spot) { create(:spot, priest: priest) }
  let!(:recurrence) { create(:recurrence, spot: spot, date: Time.zone.today,
                             start_at: '14:00', stop_at: '15:00') }
  subject { AskPriestService.new(recurrence.id) }

  context 'if recurrence id not present' do
    subject { AskPriestService.new }

    it 'handles argument error' do
      expect { subject }.to raise_error(ArgumentError, 'wrong number of arguments (0 for 1)')
    end
  end

  describe '#is_outdated' do
    context 'recurrence busy_count=2' do
      let!(:recurrence) { create(:recurrence, spot: spot, date: Time.zone.today,
                                 start_at: '14:00', stop_at: '15:00',
                                 busy_count: 2) }

      it 'return false' do
        result = subject.is_outdated

        expect(result).to be false
      end
    end
    context 'recurrence busy_count=3' do
      let!(:recurrence) { create(:recurrence, spot: spot, date: Time.zone.today,
                                 start_at: '14:00', stop_at: '15:00',
                                 busy_count: 3) }

      it 'return true' do
        result = subject.is_outdated

        expect(result).to be true
      end
    end

    context 'recurrence busy_count>3' do
      let!(:recurrence) { create(:recurrence, spot: spot, date: Time.zone.today,
                                 start_at: '14:00', stop_at: '15:00',
                                 busy_count: 4) }

      it 'return true' do
        result = subject.is_outdated

        expect(result).to be true
      end
    end
  end

end
