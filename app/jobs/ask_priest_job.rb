class AskPriestJob
  @queue = :simple

  def self.perform
    # …
    puts 'Job is done'
  end
end
