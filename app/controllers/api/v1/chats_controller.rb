module Api
  module V1
    class ChatsController < Api::V1::V1Controller
      before_action :doorkeeper_authorize!

      resource_description do
        short 'Chats'
      end

      api :GET, '/v1/messages', 'All chats of current user'
      description <<-EOS
        ## Description
        Conversations of current user with other users.
      EOS
      example <<-EOS
        [
          {
            "id": 19,
            "user": {
              "id": 19,
              "name": "Oleg",
              "surname": "Test"
            },
            "last_message": {
              "id": 28,
              "sender_id": 24,
              "recipient_id": 19,
              "text": "Hello user 19"
            }
          },
        ]
      EOS

      def index
        @user_ids = current_user.chats
        @users = User.where(id: @user_ids)
      end

      api :GET, '/v1/messages/:id', 'Messages of certain Chat'
      description <<-EOS
        ## Description
        All messages of certain Chat of current_user
      EOS
      example <<-EOS
        [
          {
            "id": 1,
            "sender_id": 1,
            "recipient_id": 9,
            "text": "Hi"
          }
        ]
      EOS

      def show
        @messages = current_user.messages.with_user(params[:id])
                                .order(created_at: :desc)
      end
    end
  end
end
