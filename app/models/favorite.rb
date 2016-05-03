class Favorite < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :priest, class_name: 'User', foreign_key: 'priest_id',
                      inverse_of: 'favorites', required: true
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
