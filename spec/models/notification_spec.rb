require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:sender) { create :user }
  let(:recipient) { create :user }
  let (:message) { create(:message, sender: sender, recipient: recipient) }
  subject { build(:notification, user: recipient, notificationable: message) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without user' do
    subject.user = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without notificationable' do
    subject.notificationable = nil
    expect(subject).not_to be_valid
  end

  it 'unread by default' do
    expect(subject).to be_unread
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
#
# Indexes
#
#  index_notifications_on_user_id                   (user_id)
#  index_notifs_on_notifable_type_and_notifable_id  (notificationable_type,notificationable_id)
#
