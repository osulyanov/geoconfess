class CleanupDynamicSpotsJob < ActiveJob::Base
  queue_as :default

  def perform
    CleanupDynamicSpotsService.new.perform
  end
end
