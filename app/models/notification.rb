class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notificationable, polymorphic: true

  default_scope -> { order unread: :desc, created_at: :desc }

  scope :unread, -> { actual.where unread: true }
  scope :actual, -> do
    where('notifications.created_at >= NOW() - \'1 month\'::INTERVAL').last 99
  end

  validates :user, presence: true
  validates :notificationable, presence: true

  after_create :send_push

  def set_read
    self.unread = false
  end

  def set_read!
    self.set_read
    self.save
  end

  def send_push
    return unless unread? && text.present? &&
      user.push_token.present? && user.notification?
    PushService.new({
                      user: user,
                      text: text,
                      aps: {
                        model: notificationable_type,
                        id: notificationable_id,
                        action: action
                      }
                    }).push!
  end
end

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
#
# Indexes
#
#  index_notifications_on_user_id                   (user_id)
#  index_notifs_on_notifable_type_and_notifable_id  (notificationable_type,notificationable_id)
#
