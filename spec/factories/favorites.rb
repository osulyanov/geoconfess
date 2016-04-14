FactoryGirl.define do
  factory :favorite do
    user { create(:user) }
    priest { create(:user, role: :priest) }
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
