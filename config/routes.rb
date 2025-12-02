Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get 'pdf_upload', to: 'statement#new' #testview (JK)
  post 'process_pdf', to: 'statement#process_pdf' #controller (JK)

  #Health Check rails
  get "up" => "rails/health#show", as: :rails_health_check

end
