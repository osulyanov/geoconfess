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
      resources :users, only: [:show, :update, :destroy] do
        member do
          put :activate
          put :deactivate
        end
      end
      resources :meet_requests, path: 'requests', except: [:new, :edit] do
        member do
          put :accept
          put :refuse
        end
      end
      resources :churches, only: [:index, :show, :create, :update, :destroy]
      resources :spots, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
