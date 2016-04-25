class AskPriestJob < ActiveJob::Base
  queue_as :default

  def perform(recurrence_id)
    AskPriestService.new(recurrence_id).notify
  end
end
