class Api::V1::NotificationsController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!
  before_action :set_notification, only: [:show, :read]
  load_and_authoreze_resource

  resource_description do
    short 'Notifications'
  end

  api! 'Actual notifications of current user'
  description <<-EOS
    ## Description
    Last 99 notifications of current user not older than 1 month
  EOS
  example <<-EOS
    # TODO
  EOS

  def index
    @notifications = current_user.notifications.actual
  end

  api! 'Show notification'
  description <<-EOS
    ## Description
    Show notification by ID
  EOS
  example <<-EOS
    TODO
  EOS

  def show
  end


  api! 'Mark notification as read'
  description <<-EOS
    Mark notification by ID as read.
    Returns code 200 with no content if notification successfully updated.
  EOS

  def read
    if @notification.set_read!
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @notification.errors }
    end
  end

  private

  def set_notification
    Notification.find(params[:id])
  end
end
