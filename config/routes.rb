Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :statements, only: [:index, :show]
  resources :opportunities, only: [:show, :update]

  get "up" => "rails/health#show", as: :rails_health_check
end
