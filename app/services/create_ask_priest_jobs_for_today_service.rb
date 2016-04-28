class CreateAskPriestJobsForTodayService
  def initialize
    @recurrences = todays_recurrences
  end

  def process
    @recurrences.each &:process_recurrence
  end

  def process_recurrence(recurrence)
    return true unless recurrence.today?
    recurrence.update_job
  end

  def todays_recurrences
    today = Time.zone.today
    Recurrence.where('recurrences.date = ? OR recurrences.date ISNULL', today)
  end
end
