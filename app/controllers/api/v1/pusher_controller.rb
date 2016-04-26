class Api::V1::PusherController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!

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
