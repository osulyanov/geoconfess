class CleanupDynamicSpotsService
  def initialize
    @outdated_spots = Spot.outdated
  end

  def perform
    @outdated_spots.destroy_all
  end
end
