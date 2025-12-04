class StatementController < ApplicationController
  def new
    #show upload form
  end


  def process_pdf
    uploaded_file = params[:pdf_file]

    # Step 1: Extract text from PDF
    pdf_text = extract_text_from_pdf(uploaded_file.path)

    # Step 2: Analyze with LLM and categorize transactions
    categorized_data = llm_categorize_transactions(pdf_text)

    # Step 3: Save to database (schema TBD by colleague)
    # save_to_database(categorized_data)

    # Step 4: Get benchmarks from database (table TBD by colleague)
    # benchmarks = get_benchmarks

    # Step 5: Generate recommendations
    # recommendations = llm_generate_recommendations(categorized_data, benchmarks)

    render plain: "Processed: #{categorized_data.inspect}"
  end

private

  def extract_text_from_pdf(file_path)
    reader = PDF::Reader.new(file_path)
    reader.pages.map(&:text).join("\n")
  end

  def llm_categorize_transactions(pdf_text)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: "You are a financial analyst. Categorize bank statement transactions." },
          { role: "user", content: "Analyze this bank statement and return JSON with transactions categorized:\n\n#{pdf_text}" }
        ]
      }
    )

    JSON.parse(response.dig("choices", 0, "message", "content"))
  rescue => e
    { error: e.message }
  end

  # def save_to_database(data)
  #   # TODO: Save to Statement model (schema from colleague)
  # end

  # def get_benchmarks
  #   # TODO: Fetch from Benchmark model (schema from colleague)
  # end

  # def llm_generate_recommendations(data, benchmarks)
  #   # TODO: Call LLM to compare data vs benchmarks
  # end
end
