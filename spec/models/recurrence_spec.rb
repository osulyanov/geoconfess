require 'rails_helper'

RSpec.describe Recurrence, type: :model do
  let(:priest) { create :user, role: :priest }
  let(:spot) { create(:spot, priest: priest) }
  subject { build(:recurrence, spot: spot) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without spot' do
    subject.spot = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without start_at' do
    subject.start_at = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without stop_at' do
    subject.stop_at = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without date and days' do
    subject.date = nil
    subject.days = nil
    expect(subject).not_to be_valid
  end

  context 'after save' do
    it 'active_date eq to current date' do
      subject.save

      result = subject.active_date

      expect(result).to eq(Time.zone.today)
    end
  end

  describe '.in_the_future' do
    let! (:recurrence_in_the_future) { create(:recurrence, spot: spot, date: 1.day.from_now) }
    let! (:recurrence_in_the_today) { create(:recurrence, spot: spot, date: Time.zone.today) }
    let! (:recurrence_in_the_past) { create(:recurrence, spot: spot, date: 1.day.ago) }

    it 'returns recurrences in the future' do
      result = described_class.in_the_future

      expect(result).to include(recurrence_in_the_future)
    end

    it 'returns recurrences for today' do
      result = described_class.in_the_future

      expect(result).to include(recurrence_in_the_future)
    end

    it 'doesn\'t return recurrences in the past' do
      result = described_class.in_the_future

      expect(result).not_to include(recurrence_in_the_past)
    end
  end

  describe '.confirmed_availability' do
    let! (:recurrence_confirmed) { create(:recurrence, spot: spot, active_date: Time.zone.today) }
    let! (:recurrence_not_confirmed) { create(:recurrence, spot: spot, active_date: 1.day.ago) }

    it 'returns recurrences with active_date eq to current date' do
      result = described_class.confirmed_availability

      expect(result).to include(recurrence_confirmed)
    end

    it 'doesn\'t return recurrences with active_date in the past' do
      result = described_class.confirmed_availability

      expect(result).not_to include(recurrence_not_confirmed)
    end
  end

  describe '.now' do
    context 'one-time' do
      it 'returns recurrence which active right now' do
        recurrence = create(:recurrence, spot: spot,
                                         date: Time.zone.today, start_at: '00:00',
                                         stop_at: '23:59')

        result = described_class.now

        expect(result).to include(recurrence)
      end

      it 'doesn\'t return recurrence if date is not today' do
        recurrence = create(:recurrence, spot: spot,
                                         date: 1.day.from_now, start_at: '00:00',
                                         stop_at: '23:59')

        result = described_class.now

        expect(result).not_to include(recurrence)
      end

      it 'doesn\'t return recurrence if current time less than start_at' do
        recurrence = create(:recurrence, spot: spot,
                                         date: Time.zone.today, start_at: '23:59',
                                         stop_at: '23:59')

        result = described_class.now

        expect(result).not_to include(recurrence)
      end

      it 'doesn\'t return recurrence if stop_at less than current time' do
        recurrence = create(:recurrence, spot: spot,
                                         date: Time.zone.today, start_at: '00:00',
                                         stop_at: '00:00')

        result = described_class.now

        expect(result).not_to include(recurrence)
      end
    end

    context 'recurred' do
      it 'returns recurrence which active right now' do
        recurrence = create(:recurrence, spot: spot, date: nil,
                                         start_at: '00:00', stop_at: '23:59',
                                         week_days: [Time.zone.today.strftime('%A')])

        result = described_class.now

        expect(result).to include(recurrence)
      end

      it 'doesn\'t return recurrence if current week day not listed' do
        wdays = Date::DAYNAMES - [Time.zone.today.strftime('%A')]

        recurrence = create(:recurrence, spot: spot, date: nil,
                                         start_at: '00:00', stop_at: '23:59',
                                         week_days: wdays)

        result = described_class.now

        expect(result).not_to include(recurrence)
      end

      it 'doesn\'t return recurrence if current time less than start_at' do
        recurrence = create(:recurrence, spot: spot, date: nil,
                                         start_at: '23:59', stop_at: '23:59',
                                         week_days: [Time.zone.today.strftime('%A')])

        result = described_class.now

        expect(result).not_to include(recurrence)
      end

      it 'doesn\'t return recurrence if stop_at less than current time' do
        recurrence = create(:recurrence, spot: spot, date: nil,
                                         start_at: '00:00', stop_at: '00:00',
                                         week_days: [Time.zone.today.strftime('%A')])

        result = described_class.now

        expect(result).not_to include(recurrence)
      end
    end
  end

  describe '#confirm_availability' do
    subject { create(:recurrence, spot: spot, busy_count: 3, active_date: 5.days.ago.to_date) }

    before do
      subject.confirm_availability
    end

    it 'resets busy_count' do
      expect(subject.busy_count).to eq(0)
    end

    it 'sets active_date to current date' do
      expect(subject.active_date).to eq(Time.zone.today)
    end

    it 'doesn\'t save changes' do
      subject.reload
      expect(subject.busy_count).to eq(3)
      expect(subject.active_date).to eq(5.days.ago.to_date)
    end
  end

  describe '#confirm_availability!' do
    subject { create(:recurrence, spot: spot, busy_count: 3, active_date: 5.days.ago.to_date) }

    before do
      subject.confirm_availability!
    end

    it 'resets busy_count' do
      expect(subject.busy_count).to eq(0)
    end

    it 'sets active_date to current date' do
      expect(subject.active_date).to eq(Time.zone.today)
    end

    it 'saves changes' do
      subject.reload
      expect(subject.busy_count).to eq(0)
      expect(subject.active_date).to eq(Time.zone.today)
    end
  end

  describe '#active_this_wday?' do
    context 'when it has current wday' do
      subject do
        create(:recurrence, spot: spot, date: nil,
                            week_days: [Time.zone.today.strftime('%A')])
      end

      it 'returns true' do
        expect(subject.active_this_wday?).to be true
      end
    end

    context 'when it hasn\'t current wday' do
      wdays = Date::DAYNAMES - [Time.zone.today.strftime('%A')]

      subject do
        create(:recurrence, spot: spot, date: nil,
                            week_days: wdays)
      end

      it 'returns true' do
        expect(subject.active_this_wday?).not_to be true
      end
    end
  end

  describe '#today?' do
    context 'one-time' do
      it 'true if date eq to current date at current time less than start_at' do
        recurrence = create(:recurrence, spot: spot,
                                         date: Time.zone.today, start_at: '23:59')

        result = recurrence.today?

        expect(result).to be true
      end

      it 'false if date not eq to current date' do
        recurrence = create(:recurrence, spot: spot,
                                         date: 1.day.from_now, start_at: '23:59')

        result = recurrence.today?

        expect(result).not_to be true
      end

      it 'false if start_at less than current time' do
        recurrence = create(:recurrence, spot: spot,
                                         date: Time.zone.today, start_at: '00:00')

        result = recurrence.today?

        expect(result).not_to be true
      end
    end

    context 'recurred' do
      it 'true if wdays include current wday at current time less than start_at' do
        recurrence = create(:recurrence, spot: spot, date: nil,
                                         week_days: [Time.zone.today.strftime('%A')],
                                         start_at: '23:59')

        result = recurrence.today?

        expect(result).to be true
      end

      it 'false if wdays not include current wday' do
        wdays = Date::DAYNAMES - [Time.zone.today.strftime('%A')]

        recurrence = create(:recurrence, spot: spot, date: nil,
                                         week_days: wdays,
                                         start_at: '23:59')

        result = recurrence.today?

        expect(result).not_to be true
      end

      it 'false if start_at less than current time' do
        recurrence = create(:recurrence, spot: spot, date: nil,
                                         week_days: [Time.zone.today.strftime('%A')],
                                         start_at: '00:00')

        result = recurrence.today?

        expect(result).not_to be true
      end
    end
  end

  describe '#start_today_at' do
    it 'returns DateTime when recurrence starts today' do
      recurrence = create(:recurrence, spot: spot,
                                       date: Time.zone.today, start_at: '12:25')

      result = recurrence.start_today_at

      expect(result).to eq(Time.zone.now.strftime '%Y-%m-%d 12:25:00 CEST +02:00')
    end
  end
end

# == Schema Information
#
# Table name: recurrences
#
#  id          :integer          not null, primary key
#  spot_id     :integer
#  date        :date
#  start_at    :time
#  stop_at     :time
#  days        :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  active_date :date
#  busy_count  :integer          default(0), not null
#
# Indexes
#
#  index_recurrences_on_spot_id  (spot_id)
#
