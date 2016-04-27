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
        resources :passwords, only: :create
      end
      post '/pusher/auth'
      get '/me' => 'credentials#show'
      get '/me/spots' => 'spots#index', me: true
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
      resources :favorites, only: [:index, :create, :destroy]
      resources :notifications, only: [:index, :show] do
        member do
          put :mark_read
        end
      end
      resources :spots, only: [:index, :show, :create, :update, :destroy] do
        member do
          resources :recurrences, only: [:index, :show, :create, :update, :destroy]
        end
      end
      resources :recurrences, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'for_priest/:priest_id', to: 'recurrences#for_priest'
        end
        member do
          put :confirm_availability
        end
      end
      resources :chats, only: [:index, :show]
      resources :messages, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
