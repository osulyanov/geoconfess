class CleanupOutdatedMessagesJob < ActiveJob::Base
  queue_as :default

  def perform
    CleanupOutdatedMessagesService.new.perform
  end
end
