class CleanupOutdatedMeetRequestsJob < ActiveJob::Base
  queue_as :default

  def perform
    CleanupOutdatedMeetRequestsService.new.perform
  end
end
