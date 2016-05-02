class CleanupOutdatedMeetRequestsService
  def initialize
    @meet_requests = meet_requests_to_remove
  end

  def perform
    @meet_requests.destroy_all
  end

  def meet_requests_to_remove
    MeetRequest.outdated
  end
end
