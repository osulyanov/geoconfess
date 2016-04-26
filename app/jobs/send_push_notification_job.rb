class SendPushNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(notification_id)
    Notification.find(notification_id).send_push
  end
end
