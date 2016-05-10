module Api
  module V1
    class PusherController < Api::V1::V1Controller
      before_action :doorkeeper_authorize!

      resource_description do
        short 'Pusher'
      end

      api :POST, '/v1/pusher/aouth', 'Authenticate subscription'
      description <<-EOS
        ## Description
        Authenticate subscription requests to private channel
      EOS
      param :channel_name, String,
            desc: 'Channel name, as "private-#{current_user.id}"',
            required: true
      param :socket_id, String,
            desc: 'socket_id, a unique identifier for the specific client
                   connection to Pusher',
            required: true

      # rubocop:disable Metrics/AbcSize
      def auth
        unless params[:channel_name] == "private-#{current_user.id}"
          head(:forbidden) && return
        end
        head(:unprocessable_entity) && return unless params[:socket_id].present?
        begin
          response = Pusher.authenticate("private-#{current_user.id}",
                                         params[:socket_id])
        rescue Pusher::Error => e
          render json: { message: e.message }, status: :unprocessable_entity
        else
          current_user.update_attribute :pusher_socket_id, params[:socket_id]
          render json: response
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
