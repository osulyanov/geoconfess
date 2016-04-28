class CreateAskPriestJobsForTodayJob < ActiveJob::Base
  queue_as :default

  def perform
    CreateAskPriestJobsForTodayService.new.process
  end
end
