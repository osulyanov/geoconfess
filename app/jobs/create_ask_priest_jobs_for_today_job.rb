class CreateAskPriestJobsForTodayJob
  @queue = :simple

  def self.perform
    today = Time.zone.today
    Rails.logger.info "CreateAskPriestJobsForTodayJob #{today}"
    # recurrences = Recurrence.where('recurrences.date = ? OR recurrences.date ISNULL', today)
    # recurrences.each do |recurrence|
    #   return unless recurrence.today?
    #   recurrence.update_job
    # end
  end
end
