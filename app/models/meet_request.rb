class MeetRequest < ActiveRecord::Base
  enum status: [:pending, :accepted, :refused]

  store_accessor :params, :latitude, :longitude

  belongs_to :priest, class_name: 'User', required: true
  belongs_to :penitent, class_name: 'User', required: true
  has_many :notifications, as: :notificationable

  scope :active, -> do
    where('meet_requests.created_at >= NOW() - \'1 day\'::INTERVAL')
  end

  scope :for_user, -> (user_id) do
    where('priest_id = ? OR penitent_id = ?', user_id, user_id)
  end

  validates :latitude, presence: true
  validates :longitude, presence: true

  after_create :send_create_notification
  after_update :send_accept_notification,
               if: Proc.new { |r| r.status_changed? && r.accepted? }
  after_update :send_refuse_notification,
               if: Proc.new { |r| r.status_changed? && r.refused? }

  def send_create_notification
    priest.notifications.create notificationable: self,
                                action: 'received',
                                text: "#{penitent.name} demande une confession!"
    penitent.notifications.create notificationable: self,
                                  action: 'sent'
  end

  def send_accept_notification
    penitent.notifications.create notificationable: self,
                                  action: 'accepted',
                                  text: 'Votre demande de confession a été acceptée!'
  end

  def send_refuse_notification
    penitent.notifications.create notificationable: self,
                                  action: 'refused',
                                  text: 'Votre demande de confession a été refusée.'
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
#  params      :hstore           default({}), not null
#
# Indexes
#
#  index_meet_requests_on_penitent_id  (penitent_id)
#  index_meet_requests_on_priest_id    (priest_id)
#
