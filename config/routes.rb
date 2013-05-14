Echidna::Application.routes.draw do
  resources :panels do
    member do
      get :trends
    end
  end

  get '/jobs/:id/status', to: 'jobs#status'

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

  namespace :tencent do
    resources :agents do
      get 'callback', on: :collection
    end
  end
end
