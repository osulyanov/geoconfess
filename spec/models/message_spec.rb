require 'rails_helper'

describe Message, type: :model do
  let(:sender) { create :user }
  let(:recipient) { create :user }
  subject { build(:message, sender: sender, recipient: recipient) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without sender' do
    subject.sender = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without recipient' do
    subject.recipient = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without text' do
    subject.text = nil
    expect(subject).not_to be_valid
  end

  describe '.with_user' do
    let (:other_user) { create(:user, role: :user) }
    let! (:message) { create(:message, sender: sender, recipient: recipient) }

    it 'returns user\'s message to certain user' do
      result = described_class.with_user(recipient.id)

      expect(result).to include(message)
    end

    it 'returns user\'s message from certain user' do
      result = described_class.with_user(sender.id)

      expect(result).to include(message)
    end

    it 'doesn\'t return message of other users' do
      result = described_class.with_user(other_user.id)

      expect(result).not_to include(message)
    end
  end
  describe '.outdated' do
    let!(:message_35d_ago) do
      create(:message, sender: sender, recipient: recipient,
                       created_at: 35.days.ago)
    end
    let!(:message_15d_ago) do
      create(:message, sender: sender, recipient: recipient,
                       created_at: 15.days.ago)
    end

    subject { described_class.outdated }

    it 'returns messages created more than a month ago' do
      expect(subject).to include(message_35d_ago)
    end

    it 'doesn\'t return messages created less than a month ago' do
      expect(subject).not_to include(message_15d_ago)
    end
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
