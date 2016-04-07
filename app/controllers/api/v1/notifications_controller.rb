class Api::V1::NotificationsController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!
  before_action :set_notification, only: [:show, :read]
  load_and_authorize_resource

  resource_description do
    short 'Notifications'
  end

  api! 'Actual notifications of current user'
  description <<-EOS
    ## Description
    Last 99 notifications of current user not older than 1 month
  EOS
  example <<-EOS
    [
      {
        "id": 3,
        "unread": false,
        "model": "MeetRequest",
        "action": "create",
        "meet_request": {
          "id": 10,
          "priest_id": 24,
          "status": "pending",
          "penitent": {
            "id": 25,
            "name": "Test user",
            "surname": "Surname",
            "latitude": "12.234",
            "longitude": "23.345"
          }
        }
      },
      {
        "id": 6,
        "unread": true,
        "model": "MeetRequest",
        "action": "sent",
        "meet_request": {
          "id": 12,
          "status": "pending",
          "penitent": {
            "id": 25
          },
          "priest": {
            "id": 24,
            "name": "Test Priest",
            "surname": "Surnemaehere"
          }
        }
      }
    ]
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
    {
      "id": 3,
      "unread": false,
      "model": "MeetRequest",
      "action": "create",
      "meet_request": {
        "id": 10,
        "priest_id": 24,
        "status": "pending",
        "penitent": {
          "id": 25,
          "name": "Test user",
          "surname": "Surname",
          "latitude": "12.234",
          "longitude": "23.345"
        }
      }
    }
  EOS

  def show
  end


  api :PUT, '/v1/notifications/:id/mark_read', 'Mark notification as read'
  description <<-EOS
    Mark notification by ID as read.
    Returns code 200 with no content if notification successfully updated.
  EOS

  def mark_read
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
