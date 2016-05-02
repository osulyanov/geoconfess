class CleanupOutdatedMeetRequestJob < ActiveJob::Base
  queue_as :default

  def perform
    CleanupOutdatedMeetRequestsService.new.perform
  end
end
