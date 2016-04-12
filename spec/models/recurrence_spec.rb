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

  context '#confirm_availability' do
    subject { create(:recurrence, spot: spot, busy_count: 3, active_date: 5.days.ago) }

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
      expect(subject.active_date).to eq(5.days.ago)
    end
  end

  context '#confirm_availability!' do
    subject { create(:recurrence, spot: spot, busy_count: 3, active_date: 5.days.ago) }

    before do
      subject.confirm_availability
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
