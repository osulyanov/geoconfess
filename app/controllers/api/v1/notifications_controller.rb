module Api
  module V1
    class NotificationsController < Api::V1::V1Controller
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
      param :last_id, Integer, desc: 'Last ID.'
      example <<-EOS
        [
          {
            "id": 3,
            "unread": false,
            "model": "MeetRequest",
            "action": "received",
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
          },
          {
            "id": 44,
            "unread": true,
            "model": "MeetRequest",
            "action": "refused",
            "meet_request": {
              "id": 18,
              "status": "refused",
              "penitent": {
                "id": 25
              },
              "priest": {
                "id": 24,
                "name": "Test Priest",
                "surname": "Surnemaehere"
              }
            }
          },
          {
            "id": 43,
            "unread": true,
            "model": "MeetRequest",
            "action": "accepted",
            "meet_request": {
              "id": 18,
              "status": "refused",
              "penitent": {
                "id": 25
              },
              "priest": {
                "id": 24,
                "name": "Test Priest",
                "surname": "Surnemaehere"
              }
            }
          },
          {
            "id": 24,
            "unread": true,
            "model": "Message",
            "action": "received",
            "message": {
              "id": 12,
              "sender_id": 24,
              "recipient_id": 24,
              "text": "Hello user 24",
              "created_at": "2016-04-27T08:58:28.917+02:00",
              "updated_at": "2016-04-27T08:58:28.917+02:00"
            }
          }
        ]
      EOS

      def index
        @notifications = current_user.notifications.actual
        if params[:last_id].present?
          @notifications = @notifications.after_id(params[:last_id])
        end
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
          "action": "received",
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
          render status: :unprocessable_entity,
                 json: { errors: @notification.errors }
        end
      end

      api :PUT, '/v1/notifications/:id/mark_sent', 'Mark notification as sent'
      description <<-EOS
        Mark notification by ID as sent.
        Returns code 200 with no content if notification successfully updated.
      EOS

      def mark_sent
        if @notification.set_sent!
          head status: :ok
        else
          render status: :unprocessable_entity,
                 json: { errors: @notification.errors }
        end
      end

      private

      def set_notification
        Notification.find_by(id: params[:id])
      end
    end
  end
end
