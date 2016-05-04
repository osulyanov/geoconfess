class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  has_one :notification, as: :notificationable, dependent: :destroy

  scope :with_user, lambda { |user_id|
    where 'messages.sender_id = ? OR messages.recipient_id = ?', user_id, user_id
  }
  scope :outdated, -> do
    where('messages.created_at < NOW() - \'1 month\'::INTERVAL')
  end

  validates :sender_id, presence: true
  validates :recipient_id, presence: true
  validates :text, presence: true

  after_create :send_create_notification

  def send_create_notification
    recipient.notifications.create notificationable: self,
                                   action: 'received',
                                   text: 'Message'
  end

  def pusher_data
    {
      sender_id: sender_id,
      text: text
    }
  end
end

# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  sender_id    :integer
#  recipient_id :integer
#  text         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_messages_on_recipient_id  (recipient_id)
#  index_messages_on_sender_id     (sender_id)
#
