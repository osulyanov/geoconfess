require 'fcm'

module PushNotification
  module Engine
    class FCM
      attr_accessor :client

      def initialize(server_key:)
        @client = ::FCM.new(server_key)
      end

      def push_to_user!(uid:, payload:)
        push!(to: "user-#{uid}", payload: payload)
      end

      def push_to_channel!(uid:, payload:)
        push!(to: "channel-#{uid}", payload: payload)
      end

      private

      def push!(to:, payload:)
        defaults = {
          content_available: true,
          priority: :high
        }
        data = defaults.merge(notification: payload)

        @client.send_to_topic(to, data)
      end
    end
  end
end
