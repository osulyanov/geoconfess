require 'rails_helper'

describe AskPriestService do
  let(:priest) { create(:user, role: :priest) }
  let(:spot) { create(:spot, priest: priest) }
  let!(:recurrence) do
    create(:recurrence, spot: spot, date: Time.zone.today,
                        start_at: '14:00', stop_at: '15:00')
  end
  subject { described_class.new(recurrence.id) }

  context 'if recurrence id not present' do
    subject { described_class.new }

    it 'handles argument error' do
      expect { subject }
        .to raise_error(ArgumentError, 'wrong number of arguments (0 for 1)')
    end
  end

  describe '#inactive?' do
    context 'recurrence busy_count=2' do
      let!(:recurrence) do
        create(:recurrence, spot: spot, date: Time.zone.today,
                            start_at: '14:00', stop_at: '15:00',
                            busy_count: 2)
      end

      it 'return false' do
        result = subject.inactive?

        expect(result).to be false
      end
    end

    context 'recurrence busy_count=3' do
      let!(:recurrence) do
        create(:recurrence, spot: spot, date: Time.zone.today,
                            start_at: '14:00', stop_at: '15:00',
                            busy_count: 3)
      end

      it 'return true' do
        result = subject.inactive?

        expect(result).to be true
      end
    end

    context 'recurrence busy_count>3' do
      let!(:recurrence) do
        create(:recurrence, spot: spot, date: Time.zone.today,
                            start_at: '14:00', stop_at: '15:00',
                            busy_count: 4)
      end

      it 'return true' do
        result = subject.inactive?

        expect(result).to be true
      end
    end
  end

  describe '#destroy_if_old' do
    context 'recurrence is inactive' do
      let!(:recurrence) do
        create(:recurrence, spot: spot, date: Time.zone.today,
                            start_at: '14:00', stop_at: '15:00',
                            busy_count: 4)
      end

      it 'return true' do
        result = subject.destroy_if_old

        expect(result).to be true
      end

      it 'removes recurrence' do
        subject.destroy_if_old

        expect { recurrence.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'recurrence is active' do
      let!(:recurrence) do
        create(:recurrence, spot: spot, date: Time.zone.today,
                            start_at: '14:00', stop_at: '15:00',
                            busy_count: 2)
      end

      it 'return false' do
        result = subject.destroy_if_old

        expect(result).to be false
      end

      it 'doesn\'t remove recurrence' do
        subject.destroy_if_old
        recurrence.reload

        expect(recurrence).to be_persisted
      end
    end
  end

  describe '#increase_busy_counter' do
    it 'increase busy_count of recurrence by 1' do
      expect { subject.increase_busy_counter }
        .to change { recurrence.reload.busy_count }.by(1)
    end
  end

  describe '#create_push' do
    it 'creates push notification object' do
      expect(PushNotification).to receive(:push_to_user!)

      subject.create_push
    end
  end
end
