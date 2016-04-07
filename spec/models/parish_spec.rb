require 'rails_helper'

RSpec.describe Parish, type: :model do
  subject { build(:parish) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without name' do
    subject.name = nil
    expect(subject).not_to be_valid
  end
end

# == Schema Information
#
# Table name: parishes
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
