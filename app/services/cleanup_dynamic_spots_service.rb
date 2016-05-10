class CleanupDynamicSpotsService
  def initialize
    @outdated_spots = spots_to_remove
  end

  # Destroys all +outdated_spots+.
  def perform
    @outdated_spots.destroy_all
  end

  # Returns outdated spots (<tt>Spot.outdated</tt>) which should be removed.
  def spots_to_remove
    Spot.outdated
  end
end
