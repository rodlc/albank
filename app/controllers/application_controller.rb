class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  protected

  def after_sign_in_path_for(resource)
    if session[:pending_pdf_key]
      process_upload_statements_path
    else
      root_path
    end
  end
end
