Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :statements, only: [:index, :show, :new, :create] do
    resources :expenses, only: [:index, :show] do
      resources :opportunities, only: [:show, :update]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
