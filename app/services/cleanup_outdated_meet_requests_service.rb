class CleanupOutdatedMeetRequestsService
  def initialize
    @meet_requests = meet_requests_to_remove
  end

  # Destroys all +meet_requests_to_remove+.
  def perform
    @meet_requests.destroy_all
  end

  # Returns collection of outdated meet requests (<tt>MeetRequest.outdated</tt>)
  # to remove them.
  def meet_requests_to_remove
    MeetRequest.outdated
  end
end
