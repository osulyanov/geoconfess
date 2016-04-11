class AskPriestJob
  @queue = :simple

  def self.perform(recurrence_id)
    Rails.logger.info "AskPriestJob #{recurrence_id}"

    recurrence = Recurrence.includes(:spot, spot: [:priest]).find(recurrence_id)
    spot = recurrence.spot

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
