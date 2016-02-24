class Spot < ActiveRecord::Base
  belongs_to :priest, class_name: 'User', required: true
  belongs_to :church, required: true
  has_many :recurrences, dependent: :destroy

  validates :name, presence: true
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
