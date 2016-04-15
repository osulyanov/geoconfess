class CleanupDynamicSpotsJob < ActiveJob::Base
  queue_as :default

  def perform
    Spot.outdated.destroy_all
  end
end
