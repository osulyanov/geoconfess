require 'rails_helper'

describe CleanupDynamicSpotsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect(CleanupDynamicSpotsService).to receive_message_chain(:new, :perform)

    perform_enqueued_jobs { job }
  end
end
