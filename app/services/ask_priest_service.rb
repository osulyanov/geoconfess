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
  # Otherwise sends push notifications.
  def notify
    return if destroy_if_old

    increase_busy_counter

    create_push
  end

  # Checks if priest doesn't available for 3 times before that.
  #
  # Returns +true+ if +busy_count+ of recurrence equal or more than 3,
  # +false+ otherwise.
  #
  #   # If +busy_count+ is 2
  #   inactive? # => false
  #
  #   # If +busy_count+ is 3
  #   inactive? # => true
  def inactive?
    @recurrence.busy_count >= 3
  end

  # Destroys recurrence if inactive (+inactive?+ returns +true+) and
  # returns +true+, otherwise returns +false+.
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
    PushNotification.push_to_user!(uid: @spot.priest.id, payload: push_payload)
  end

  # rubocop:disable Metrics/MethodLength
  def push_payload
    {
      sound: 'default',
      body: 'Confirmez votre disponibilité pour confesser!',
      data: {
        user_id: @spot.priest.id,
        model: 'Recurrence',
        id: @recurrence_id,
        action: 'availability',
        notification_id: nil
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end
