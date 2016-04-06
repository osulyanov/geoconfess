class MeetRequest < ActiveRecord::Base
  enum status: [:pending, :accepted, :refused]

  store_accessor :params, :latitude, :longitude

  belongs_to :priest, class_name: 'User', required: true
  belongs_to :penitent, class_name: 'User', required: true

  scope :active, -> do
    where('meet_requests.created_at >= NOW() - \'1 day\'::INTERVAL')
  end

  scope :for_user, -> (user_id) do
    where('priest_id = ? OR penitent_id = ?', user_id, user_id)
  end

  validates :latitude, presence: true
  validates :longitude, presence: true
end

# == Schema Information
#
# Table name: meet_requests
#
#  id          :integer          not null, primary key
#  priest_id   :integer
#  penitent_id :integer
#  status      :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  params      :hstore           default({}), not null
#
# Indexes
#
#  index_meet_requests_on_penitent_id  (penitent_id)
#  index_meet_requests_on_priest_id    (priest_id)
#
