require 'rails_helper'

RSpec.describe Spot, type: :model do
  let(:parish) { create :parish }
  let(:priest) { create :user, role: :priest, parish: parish }
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
#  id         :integer          not null, primary key
#  name       :string
#  priest_id  :integer
#  church_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_spots_on_church_id  (church_id)
#  index_spots_on_priest_id  (priest_id)
#
