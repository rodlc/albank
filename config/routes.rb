Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get 'pdf_upload', to: 'pdf_processing#new' #testview (JK)
  post 'process_pdf', to: 'pdf_processing#process_pdf' #controller (JK)

  #Health Check rails
  get "up" => "rails/health#show", as: :rails_health_check

end
