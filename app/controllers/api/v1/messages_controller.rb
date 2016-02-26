class Api::V1::MessagesController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!
  before_action :set_message, only: [:show, :update, :destroy]
  load_and_authorize_resource

  resource_description do
    short 'Messages'
  end

  def_param_group :message do
    param :message, Hash, desc: 'User info' do
      param :sender_id, Integer, desc: 'Sender ID. For admin only.', required: true
      param :recipient_id, Integer, desc: 'Recipient ID', required: true
      param :text, String, desc: 'Message text', required: true
    end
  end

  api! 'All messages of current user'
  description <<-EOS
    ## Description
    All messages where sender_id or recipient_id equal to current_user.id
  EOS
  param :interlocutor_id, Integer, desc: 'Filter by interlocutor'
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

  def index
    @messages = current_user.messages
    @messages = @messages.with_user(params[:interlocutor_id]) if params[:interlocutor_id].present?
  end


  api! 'Show message'
  description <<-EOS
    ## Description
    Show message with certain ID
  EOS
  example <<-EOS
    {
      "id": 1,
      "sender_id": 1,
      "recipient_id": 9,
      "text": "Hi"
    }
  EOS

  def show
  end


  api! 'Create message'
  description <<-EOS
    ## Description
    Creates message
    Returns code 201 with no content if message successfully created.
  EOS
  param_group :message

  def create
    @message = Message.new(message_params)
    @message.sender_id ||= current_user.id
    if @message.save
      head status: :created
    else
      render status: :unprocessable_entity, json: { errors: @message.errors }
    end
  end


  api! 'Update message'
  description <<-EOS
    ## Description
    Updates message data
    Returns code 200 with no content if message successfully updated.
  EOS
  param_group :message

  def update
    if @message.update_attributes(message_params)
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @message.errors }
    end
  end


  api! 'Destroy message'
  description <<-EOS
    ## Description
    Destroys message
    Returns code 200 with no content if message successfully destroyed.
  EOS

  def destroy
    if @message.destroy
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @message.errors }
    end
  end

  private

  def message_params
    params.require(:message).permit(:recipient_id, :sender_id, :text).tap do |wl|
      # Don't allow sender for non-admin users
      wl.delete(:sender_id) unless current_user.admin?
    end
  end

  def set_message
    @message = Message.find(params[:id])
  end
end
