class CreateAskPriestJobsForTodayService
  def initialize
    @recurrences = todays_recurrences
  end

  # Updates job of every recurrence by running processing of each of them.
  def process
    @recurrences.each { |r| process_recurrence(r) }
  end

  # Updates job of a recurrence.
  #
  # Doesn't do anything and return +true+ unless the recurrence happens today.
  # Update job of recurrence if it happens today.
  def process_recurrence(recurrence)
    return true unless recurrence.today?
    recurrence.update_job
  end

  # Returns a collection of recurrences which perhaps happens today.
  #
  # It's collection with date equal to current date and with empty date.
  def todays_recurrences
    today = Time.zone.today
    Recurrence.where('recurrences.date = ? OR recurrences.date ISNULL', today)
  end
end
