require 'rails_helper'

describe Notification, type: :model do
  let(:sender) { create :user }
  let(:recipient) { create :user }
  let(:message) { create(:message, sender: sender, recipient: recipient) }
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

  it 'unsent by default' do
    expect(subject).not_to be_sent
  end

  describe '.unread' do
    let!(:unread) do
      create(:notification, user: recipient, notificationable: message)
    end
    let!(:read) do
      create(:notification, user: recipient, notificationable: message,
             unread: false)
    end
    subject { described_class.unread }

    it 'returns unread notification' do
      expect(subject).to include(unread)
    end

    it 'doesn\'t return read notification' do
      expect(subject).not_to include(read)
    end
  end

  describe '.unsent' do
    let!(:unsent) do
      create(:notification, user: recipient, notificationable: message)
    end
    let!(:sent) do
      create(:notification, user: recipient, notificationable: message,
             sent: true)
    end
    subject { described_class.unsent }

    it 'returns unsent notification' do
      expect(subject).to include(unsent)
    end

    it 'doesn\'t return sent notification' do
      expect(subject).not_to include(sent)
    end
  end

  describe '.actual' do
    before do
      250.times do
        create(:notification, user: recipient, notificationable: message,
               created_at: rand(60).days.ago)
      end
    end
    subject { described_class.actual }

    it 'returns no more than 99 notification' do
      expect(subject.size).not_to be > 99
    end

    it 'returns notification created les than 1 month ago' do
      expect(subject.last.created_at).to be > 1.month.ago
    end
  end

  describe '#set_read' do
    subject do
      create(:notification, user: recipient, notificationable: message)
    end
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
    subject do
      create(:notification, user: recipient, notificationable: message)
    end
    before { subject.set_read! }

    it 'set unread to false and save changes' do
      subject.reload
      expect(subject).not_to be_unread
    end
  end

  describe '#set_sent' do
    subject do
      create(:notification, user: recipient, notificationable: message)
    end
    before { subject.set_sent }

    it 'set sent to true' do
      expect(subject).to be_sent
    end

    it 'doesn\'t save changes' do
      subject.reload
      expect(subject).not_to be_sent
    end
  end

  describe '#set_sent!' do
    subject do
      create(:notification, user: recipient, notificationable: message)
    end
    before { subject.set_sent! }

    it 'set sent to true and save changes' do
      subject.reload
      expect(subject).to be_sent
    end
  end

  describe '#send_push' do
    include ActiveJob::TestHelper

    context 'sends push' do
      xit 'if unread with text and user has push_token and turned on
          notifications', perform_enqueued: true do
        expect(Pusher).to receive(:trigger).exactly(2).times
        expect(PushNotification).to receive(:push_to_user!).exactly(2).times

        perform_enqueued_jobs do
          create(:notification, user: recipient,
                                notificationable: message,
                                text: 'Some text',
                                action: 'created')
        end
      end
    end

    context 'doesn\'t send push if' do
      it 'notification is sent' do
        expect(PushNotification).not_to receive(:push_to_user!)

        create(:notification, user: recipient, sent: true,
                                             notificationable: message,
                                             text: 'Some text',
                                             action: 'created')
      end

      it 'text is empty' do
        expect(PushNotification).not_to receive(:push_to_user!)

        create(:notification, user: recipient,
                              notificationable: message,
                              text: '',
                              action: 'created')
      end

      it 'user turned off notifications' do
        recipient = create(:user, notification: false)

        expect(PushNotification).not_to receive(:push_to_user!)

        create(:notification, user: recipient,
                              notificationable: message,
                              text: '',
                              action: 'created')
      end
    end
  end
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
