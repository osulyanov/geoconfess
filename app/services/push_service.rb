class PushService
  def initialize(params)
    @user = params[:user]
    @text = params[:text]
    @badge = @user.notifications.unread.size
    @aps = params[:aps] || {}
  end

  def push
    Rails.logger.info "push - add to queue"
    return false unless @user.push_token.present? && @text.present?
    send("push_#{@user.os}")
  end

  def push!
    Rails.logger.info "push - creating"
    if notification = push
      Rails.logger.info "push - send"
      notification.app.push_notifications
    end
  end

  def push_ios
    app = RailsPushNotifications::APNSApp.first
    app.notifications.create(
      destinations: [@user.push_token],
      data: {
        aps: { alert: @text, sound: 'true', badge: @badge }
      }
    )
  end

  def push_android
    app = RailsPushNotifications::APNSApp.first
    app.notifications.create(
      destinations: [@user.push_token],
      data: { text: @text }
    )
  end
end
