class MeetRequest < ActiveRecord::Base
  enum status: [:pending, :accepted, :refused]

  belongs_to :priest, class_name: 'User', required: true
  belongs_to :penitent, class_name: 'User', required: true

  scope :all_for_user, -> (user_id) do
    where('priest_id = ? OR penitent_id = ?', user_id, user_id)
  end
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
#
# Indexes
#
#  index_meet_requests_on_penitent_id  (penitent_id)
#  index_meet_requests_on_priest_id    (priest_id)
#
