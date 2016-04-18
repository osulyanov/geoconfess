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

  describe '.unread' do
    let! (:unread) { create(:notification, user: recipient, notificationable: message) }
    let! (:read) { create(:notification, user: recipient, notificationable: message, unread: false) }
    subject { Notification.unread }

    it 'returns unread notification' do
      expect(subject).to include(unread)
    end

    it 'doesn\'t return read notification' do
      expect(subject).not_to include(read)
    end
  end

  describe '.actual' do
    before do
      250.times do
        create(:notification, user: recipient, notificationable: message, created_at: rand(60).days.ago)
      end
    end
    subject { Notification.actual }

    it 'returns no more than 99 notification' do
      expect(subject.size).not_to be > 99
    end

    it 'returns notification created les than 1 month ago' do
      expect(subject.last.created_at).to be > 1.month.ago
    end
  end

  describe '#set_read' do
    subject { create(:notification, user: recipient, notificationable: message) }
    before { subject.set_read }

    it 'set unread to false' do
      expect(subject).not_to be_unread
    end

    it 'doesn\'t save changes' do
      subject.reload
      expect(subject).to be_unread
    end
  end

  describe '#set_read!' do
    subject { create(:notification, user: recipient, notificationable: message) }
    before { subject.set_read! }

    it 'set unread to false and save changes' do
      subject.reload
      expect(subject).not_to be_unread
    end
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
