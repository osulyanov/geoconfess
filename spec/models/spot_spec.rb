require 'rails_helper'

RSpec.describe Spot, type: :model do
  let(:priest) { create :user, role: :priest }
  let(:church) { create :church }
  subject { build(:spot, priest: priest, church: church) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without priest' do
    subject.priest = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without church' do
    subject.church = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without name' do
    subject.name = nil
    expect(subject).not_to be_valid
  end
end

# == Schema Information
#
# Table name: spots
#
#  id            :integer          not null, primary key
#  name          :string
#  priest_id     :integer
#  church_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  activity_type :integer          default(0), not null
#  latitude      :float
#  longitude     :float
#
# Indexes
#
#  index_spots_on_church_id  (church_id)
#  index_spots_on_priest_id  (priest_id)
#
