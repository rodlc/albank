class PdfProcessingController < ApplicationController
  def new
    #show upload form
  end


  def process_pdf
    uploaded_file = params[:pdf_file]
    file_name = uploaded_file.original_filename
      render plain: "Successfully processed PDF file: #{file_name}"
  end



end
