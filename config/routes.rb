Rails.application.routes.draw do
  root 'home#index'

  apipie
  use_doorkeeper
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, path: 'v1' do
      devise_scope :user do
        post '/registrations' => 'registrations#create'
        put '/me' => 'credentials#update'
      end
      get '/me' => 'credentials#show'
    end
  end
end
