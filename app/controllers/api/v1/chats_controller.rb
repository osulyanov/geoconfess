class Api::V1::ChatsController < Api::V1::V1Controller
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
    chats = current_user.messages
    chats = chats.select('DISTINCT ON (sender_id, recipient_id) *')
    chats.to_a.sort! { |f, s| s.created_at <=> f.created_at }
    @user_ids = []
    chats.each do |chat|
      @user_ids.push(chat.sender_id) unless current_user.id == chat.sender_id || @user_ids.include?(chat.sender_id)
      @user_ids.push(chat.recipient_id) unless current_user.id == chat.recipient_id || @user_ids.include?(chat.recipient_id)
    end
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
    @messages = current_user.messages.with_user(params[:id]).order(created_at: :desc)
  end
end
