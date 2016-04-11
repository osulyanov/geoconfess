class PushService
  def initialize(params)
    @user = params[:user]
    @text = params[:text]
    @badge = @user.notifications.unread.size
    @aps = params[:aps] || {}
  end

  def push
    if @user.push_token.present? && @text.present?
      Rails.logger.info "push - create push"
      send("push_#{@user.os}")
    else
      Rails.logger.info "push - push_token or text doesn't present"
    end
  end

  def push!
    Rails.logger.info "push - creating"
    notification = push
    Rails.logger.info "push - send"
    notification.app.push_notifications
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
