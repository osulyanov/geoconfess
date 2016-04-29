class CleanupOutdatedMeetRequestJob < ActiveJob::Base
  queue_as :default

  def perform
    MeetRequest.outdated.destroy_all
  end
end
