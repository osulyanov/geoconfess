require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let (:priest) { create(:user, role: :priest) }
  let (:user) { create(:user, role: :user) }
  subject { build(:favorite, priest: priest, user: user) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without priest' do
    subject.priest = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without user' do
    subject.user = nil
    expect(subject).not_to be_valid
  end
end

# == Schema Information
#
# Table name: favorites
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  priest_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_favorites_on_priest_id  (priest_id)
#  index_favorites_on_user_id    (user_id)
#
