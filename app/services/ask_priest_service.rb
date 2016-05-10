class AskPriestService
  def initialize(recurrence_id)
    @recurrence = Recurrence.includes(:spot, spot: [:priest])
                            .find_by(id: recurrence_id)
    @spot = @recurrence.spot
  end

  # Sends push notification to priest to ask him to confirm his availability
  # for the recurrence.
  #
  # Returns false and removes recurrence if priest haven't confirmed his
  # availability for 3 times before that.
  #
  # Otherwise creates sends push notifications.
  def notify
    return if destroy_if_old

    increase_busy_counter

    create_push
  end

  # Checks if priest doesn't available for 3 times before that.
  #
  # Returns +true+ if +busy_count+ of recurrence equal or more than 3,
  # +false+ otherwise.
  def inactive?
    @recurrence.busy_count >= 3
  end

  # Destroy recurrence if inactive (+inactive?+ returns +true+) and
  # returns +true+. Returns +false+ otherwise.
  def destroy_if_old
    return false unless inactive?
    # Completely remove the recurrence
    @recurrence.destroy
    true
  end

  # Increment busy counter of recurrence.
  #
  # Increases by +busy_count+ of recurrence by 1.
  def increase_busy_counter
    @recurrence.increment! :busy_count
  end

  # Sends push notification to priest to ask him to confirm his availability
  # for the recurrence.
  #
  # Creates new +PushService+ object and call +push!+ method to it.
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
