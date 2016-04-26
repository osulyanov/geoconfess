require 'rails_helper'

RSpec.describe AskPriestJob, type: :job do
  include ActiveJob::TestHelper

  let(:priest) { create(:user, role: :priest) }
  let(:spot) { create(:spot, priest: priest) }
  let!(:recurrence) { create(:recurrence, spot: spot, date: Time.zone.today,
                             start_at: '14:00', stop_at: '15:00') }
  subject(:job) { described_class.perform_later(recurrence.id) }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect(AskPriestService).to receive_message_chain(:new, :notify)
    perform_enqueued_jobs { job }
  end
end
