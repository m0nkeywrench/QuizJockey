Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  root to: "courses#index"

  namespace :courses do
    resources :searches, only: :index
  end

  resources :courses do
    resources :questions, except: [:show]
  end

  resources :users, only: :index do
    member do
      get "profile_edit"
      patch "profile_update"
    end
  end
end
