namespace :push do
  desc 'Create both app'
  task(apps: [:ios_app, :android_app]) {}

  desc 'Create iOS app'
  task ios_app: :environment do
    puts 'remove old app'
    RailsPushNotifications::APNSApp.destroy_all
    puts 'create a new one'
    app = RailsPushNotifications::APNSApp.new
    app.apns_dev_cert = File.read('config/production.pem')
    app.apns_prod_cert = File.read('config/production.pem')
    app.sandbox_mode = false
    app.save!
  end

  desc 'Create Android app'
  task android_app: :environment do
    puts 'remove old app'
    RailsPushNotifications::APNSApp.destroy_all
    puts 'create a new one'
    app = RailsPushNotifications::GCMApp.new
    app.gcm_key = Rails.application.secrets.android_push_key
    app.save!
  end
end
