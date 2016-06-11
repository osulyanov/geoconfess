class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notificationable, polymorphic: true

  default_scope -> { order unread: :desc, created_at: :desc }

  scope :unread, -> { actual.where unread: true }
  scope :unsent, -> { actual.where sent: false }
  scope :actual, lambda {
    where('notifications.created_at >= NOW() - \'1 month\'::INTERVAL').limit 99
  }
  scope :after_id, -> (id) { where 'notifications.id > ?', id.to_i }

  validates :user, presence: true
  validates :notificationable, presence: true

  after_create :send_notifications

  def set_read
    self.unread = false
  end

  def set_read!
    set_read
    save
  end

  def set_sent
    self.sent = true
  end

  def set_sent!
    set_sent
    save
  end

  def send_notifications
    SendPushNotificationJob.perform_later(id)
  end

  def send_pusher
    pusher_data = notificationable.pusher_data
    pusher_data[:notification_id] = id
    Pusher.trigger(notificationable.recipient.channel,
                   "#{notificationable_type}:#{action}", pusher_data)
  end

  def send_push
    return unless !sent? && text.present? && user.notification?
    PushNotification.push_to_user!(uid: user.id, payload: push_payload)
  end

  # rubocop:disable Metrics/MethodLength
  def push_payload
    {
      sound: 'default',
      body: text,
      data: {
        user_id: user.id,
        model: notificationable_type,
        id: notificationable_id,
        action: action,
        notification_id: id
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end

# rubocop:disable Metrics/LineLength

# == Schema Information
#
# Table name: notifications
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  notificationable_id   :integer
#  notificationable_type :string
#  unread                :boolean          default(TRUE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  action                :string
#  text                  :string
#  sent                  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_notifications_on_user_id                   (user_id)
#  index_notifs_on_notifable_type_and_notifable_id  (notificationable_type,notificationable_id)
#

# rubocop:enable Metrics/LineLength
