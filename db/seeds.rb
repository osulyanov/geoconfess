# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create!(email: 'admin@example.com', password: '1q2w3e4r',
             password_confirmation: '1q2w3e4r', role: :admin, name: 'Admin',
             surname: 'Admin')

app = RailsPushNotifications::APNSApp.new
app.apns_dev_cert = File.read('config/production.pem')
app.apns_prod_cert = File.read('config/production.pem')
app.sandbox_mode = false
app.save!

app = RailsPushNotifications::GCMApp.new
app.gcm_key = Rails.application.secrets.android_push_key
app.save!