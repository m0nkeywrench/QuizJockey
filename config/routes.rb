Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  root to: "courses#index"
  resources :courses do
    resources :questions, except: [:show]
  end
  resources :users, only: [:show] do
    member do
      get "profile_edit"
      patch "profile_update"
    end
  end
end
