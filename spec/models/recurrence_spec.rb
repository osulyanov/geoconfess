require 'rails_helper'

RSpec.describe Recurrence, type: :model do
  let(:priest) { create :user, role: :priest }
  let(:church) { create :church }
  let(:spot) { create(:spot, priest: priest, church: church) }
  subject { build(:recurrence, spot: spot) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without spot' do
    subject.spot = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without date and days' do
    subject.date = nil
    subject.days = nil
    expect(subject).not_to be_valid
  end

  describe '.in_the_future' do
    let! (:recurrence_in_the_future) { create(:recurrence, spot: spot, date: 1.day.from_now) }
    let! (:recurrence_in_the_today) { create(:recurrence, spot: spot, date: Time.zone.today) }
    let! (:recurrence_in_the_past) { create(:recurrence, spot: spot, date: 1.day.ago) }

    it 'returns recurrences in the future' do
      result = Recurrence.in_the_future

      expect(result).to include(recurrence_in_the_future)
    end

    it 'returns recurrences for today' do
      result = Recurrence.in_the_future

      expect(result).to include(recurrence_in_the_future)
    end

    it 'doesn\'t return recurrences in the past' do
      result = Recurrence.in_the_future

      expect(result).not_to include(recurrence_in_the_past)
    end
  end

  describe '.confirmed_availability' do
    let! (:recurrence_confirmed) { create(:recurrence, spot: spot, active_date: Time.zone.today) }
    let! (:recurrence_not_confirmed) { create(:recurrence, spot: spot, active_date: 1.day.ago) }

    it 'returns recurrences with active_date eq to current date' do
      result = Recurrence.confirmed_availability

      expect(result).to include(recurrence_confirmed)
    end

    it 'doesn\'t return recurrences with active_date in the past' do
      result = Recurrence.confirmed_availability

      expect(result).not_to include(recurrence_not_confirmed)
    end
  end

  context '#confirm_availability' do
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

  context '#confirm_availability!' do
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
