class CreateAskPriestJobsForTodayJob < ActiveJob::Base
  queue_as :default

  def perform
    today = Time.zone.today
    recurrences = Recurrence.where('recurrences.date = ? OR recurrences.date ISNULL', today)
    recurrences.each do |recurrence|
      next unless recurrence.today?
      recurrence.update_job
    end
  end
end
