class AskPriestJob
  @queue = :simple

  def self.perform(recurrence_id)
    Rails.logger.info "AskPriestJob #{recurrence_id}"

    recurrence = Recurrence.includes(:spot, spot: [:priest]).find(recurrence_id)
    spot = recurrence.spot

    # Check if priest doesn't available for 3 times before that
    if recurrence.busy_count >= 3
      # Completely remove the recurrence
      recurrence.destroy
      return
    end

    # Increase busy counter
    recurrence.increment! :busy_count

    PushService.new({
                      user: spot.priest,
                      text: 'Confirmez votre disponibilité pour confesser!',
                      aps: {
                        model: 'Recurrence',
                        id: recurrence_id,
                        action: 'availability'
                      }
                    }).push!
  end
end
