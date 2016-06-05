PushNotification.configure do |config|
  config.engine = PushNotification::Engine::FCM.new(server_key: Rails.application.secrets.fcm_server_key)
end
