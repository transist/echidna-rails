Echidna::Application.routes.draw do
  resources :panels do
    member do
      get :trends
      get :tweets
    end
  end

  resources :tencent_agents

  get '/jobs/:id/status', to: 'jobs#status'

  authenticated :user do
    root to: 'panels#index'
    post 'add_stopword' => 'users#add_stopword'
  end
  root to: 'home#index'
  devise_for :users
  resources :users

  authenticated :user do
    require 'sidekiq/web'
    require 'sidekiq_status/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :tencent do
    resources :agents do
      get 'callback', on: :collection
    end
  end

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
end
