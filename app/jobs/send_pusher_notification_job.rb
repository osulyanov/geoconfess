class SendPusherNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(notification_id)
    Notification.find_by(id: notification_id).send_pusher
  end
end
