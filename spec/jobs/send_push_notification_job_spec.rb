require 'rails_helper'

describe SendPushNotificationJob, type: :job do
  include ActiveJob::TestHelper

  let(:sender) { create(:user) }
  let(:recipient) { create(:user) }
  let(:message) { create(:message, sender: sender, recipient: recipient) }
  let!(:notification) { create(:notification, user: recipient, notificationable: message) }
  subject(:job) { described_class.perform_later(notification.id) }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect(Notification).to receive_message_chain(:find_by, :send_push)
    perform_enqueued_jobs { job }
  end
end
