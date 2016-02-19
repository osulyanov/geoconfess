Rails.application.routes.draw do
  use_doorkeeper
  root 'home#index'
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
