#ruby=2.2.4
#ruby-gemset=geoconfess

source 'https://rubygems.org'

gem 'rails', '4.2.5.1'
gem 'pg', '~> 0.15'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
# gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'devise'
gem 'activeadmin', github: 'activeadmin'
gem 'cancancan', '~> 1.10'
gem 'doorkeeper'
gem 'apipie-rails', github: 'Apipie/apipie-rails'
gem 'maruku'
gem 'week_sauce'
gem 'country_select'
gem 'postmark-rails'
gem 'rails-push-notifications', '~> 0.2.0'
gem 'resque'
gem 'resque-scheduler'
gem 'active_scheduler'
gem 'geocoder'
gem 'pusher'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'fcm'

group :production do
  gem 'rails_12factor'
  gem 'newrelic_rpm'
  gem 'rollbar'
end

group :development, :test do
  gem 'byebug'
  gem 'oauth2'
  gem 'annotate', github: 'ctran/annotate_models'
end

group :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'database_cleaner'
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'webmock'
  gem 'vcr'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'letter_opener'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
end
