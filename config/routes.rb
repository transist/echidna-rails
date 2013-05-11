Echidna::Application.routes.draw do
  resources :panels do
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
end
