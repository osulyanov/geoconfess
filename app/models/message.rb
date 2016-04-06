class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  has_one :notification, as: :notificationable

  scope :with_user, lambda { |user_id|
    where 'messages.sender_id = ? OR messages.recipient_id = ?', user_id, user_id
  }

  validates :sender_id, presence: true
  validates :recipient_id, presence: true
  validates :text, presence: true
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
