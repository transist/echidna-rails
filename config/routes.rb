Echidna::Application.routes.draw do
  resources :groups do
    member do
      get :trends
    end
  end

  authenticated :user do
    root to: 'home#dashboard'
  end
  root to: 'home#index'
  devise_for :users
  resources :users

  authenticated :user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
