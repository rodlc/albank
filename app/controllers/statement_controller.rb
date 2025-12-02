class StatementController < ApplicationController
  def new
    #show upload form
  end


  def process_pdf
    uploaded_file = params[:pdf_file]
    file_name = uploaded_file.original_filename
      render plain: "Successfully processed PDF file: #{file_name}"
  end



private
  # def extract_text_from_pdf(file_path)
  # #.  input =
  # end

  # def llm_analyzer()
  #   #
  # end


end
