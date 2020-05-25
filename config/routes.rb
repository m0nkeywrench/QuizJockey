Rails.application.routes.draw do
  devise_for :users
  root to: "courses#index"
  resources :courses do
    resources :questions, except: [:show, :edit]
  end
  resources :users, only: [:show]
end
