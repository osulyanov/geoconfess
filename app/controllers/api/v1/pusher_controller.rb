class Api::V1::PusherController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!

  resource_description do
    short 'Pusher'
  end

  api :POST, '/v1/pusher/aouth', 'Authenticate subscription'
  description <<-EOS
    ## Description
    Authenticate subscription requests to private channel
  EOS
  param :channel_name, String, desc: 'Channel name, as "private-#{current_user.id}"', required: true

  def auth
    unless params[:channel_name] == "private-#{current_user.id}"
      head :forbidden and return
    end
    begin
      response = Pusher.authenticate("private-#{current_user.id}", params[:socket_id])
    rescue Pusher::Error => e
      render json: { message: e.message }, status: :unprocessable_entity
    else
      current_user.update_attribute :pusher_socket_id, params[:socket_id]
      render json: response
    end
  end
end
