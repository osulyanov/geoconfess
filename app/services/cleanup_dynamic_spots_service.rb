class CleanupDynamicSpotsService
  def initialize
    @outdated_spots = spots_to_remove
  end

  def perform
    @outdated_spots.destroy_all
  end

  def spots_to_remove
    Spot.outdated
  end
end
