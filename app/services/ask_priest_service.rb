class AskPriestService
  def initialize(recurrence_id)
    @recurrence = Recurrence.includes(:spot, spot: [:priest])
                            .find_by(id: recurrence_id)
    @spot = @recurrence.spot
  end

  def notify
    return if destroy_if_old

    increase_busy_counter

    create_push
  end

  # Check if priest doesn't available for 3 times before that
  def inactive?
    @recurrence.busy_count >= 3
  end

  def destroy_if_old
    return false unless inactive?
    # Completely remove the recurrence
    @recurrence.destroy
    true
  end

  # Increase busy counter
  def increase_busy_counter
    @recurrence.increment! :busy_count
  end

  def create_push
    PushService.new(user: @spot.priest,
                    text: 'Confirmez votre disponibilité pour confesser!',
                    aps: {
                      model: 'Recurrence',
                      id: @recurrence_id,
                      action: 'availability'
                    }).push!
  end
end
