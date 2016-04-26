class SendPusherNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(notification_id)
    Notification.find(notification_id).send_pusher
  end
end
