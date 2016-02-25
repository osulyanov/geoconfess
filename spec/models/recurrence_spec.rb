require 'rails_helper'

RSpec.describe Recurrence, type: :model do
  let(:parish) { create :parish }
  let(:priest) { create :user, role: :priest, parish: parish }
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
end

# == Schema Information
#
# Table name: recurrences
#
#  id         :integer          not null, primary key
#  spot_id    :integer
#  date       :date
#  start_at   :time
#  stop_at    :time
#  days       :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_recurrences_on_spot_id  (spot_id)
#
