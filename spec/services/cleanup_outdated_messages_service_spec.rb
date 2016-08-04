require 'rails_helper'

describe CleanupOutdatedMessagesService do
  let(:sender) { create :user }
  let(:recipient) { create :user }
  let!(:message_35h_ago) do
    create(:message, sender: sender, recipient: recipient,
                     created_at: 35.hours.ago)
  end
  let!(:message_15h_ago) do
    create(:message, sender: sender, recipient: recipient,
                     created_at: 15.hours.ago)
  end

  subject { described_class.new }

  describe '#messages_to_remove' do
    it 'returns outdated messages' do
      result = subject.messages_to_remove

      expect(result).to include(message_35h_ago)
    end

    it 'doesn\'t return actual messages' do
      result = subject.messages_to_remove

      expect(result).not_to include(message_15h_ago)
    end
  end

  describe '#perform' do
    it 'removes outdated messages' do
      subject.perform

      result = Message.all

      expect(result).not_to include(message_35h_ago)
    end

    it 'doesn\'t remove actual messages' do
      subject.perform

      result = Message.all

      expect(result).to include(message_15h_ago)
    end
  end
end
