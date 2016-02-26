require 'rails_helper'

RSpec.describe Message, type: :model do
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
