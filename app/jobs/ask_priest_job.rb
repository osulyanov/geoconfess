class AskPriestJob
  @queue = :simple

  def self.perform(str)
    # …
    Rails.logger.info "Job is done! #{str}"
    puts "Job is done! #{str}"
  end
end
