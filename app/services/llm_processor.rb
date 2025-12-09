class LlmProcessor
  MODELS = %w[
    google/gemini-2.0-flash-exp:free
    meta-llama/llama-3.3-70b-instruct:free
    deepseek/deepseek-chat-v3-0324:free
  ].freeze

  def initialize(text)
    @text = text
    @categories = Category.pluck(:name)
  end

  def process
    models_to_try = ENV["LLM_MODEL"] ? [ENV["LLM_MODEL"]] + MODELS : MODELS

    models_to_try.each do |model|
      result = try_model(model)
      return result if result[:transactions].any?
    end

    Rails.logger.error("[LLM] Tous les modèles ont échoué")
    { transactions: [] }
  end

  private

  def try_model(model)
    Rails.logger.info("[LLM] Essai avec #{model}")
    chat = RubyLLM.chat(model: model, provider: :openrouter)
    response = chat.ask(prompt)
    parse_response(response.content)
  rescue StandardError => e
    Rails.logger.warn("[LLM] #{model} échoué: #{e.message}")
    { transactions: [] }
  end

  def prompt
    <<~PROMPT
      Voici le contenu de mon relevé bancaire :
      #{@text}

      Catégorise les dépenses suivantes et enrichis chaque libellé.

      Attribue une catégorie parmi :
      #{@categories.join(", ")}

      Réponds uniquement en JSON avec les clés, en reprenant toutes les lignes de dépenses, avec cette forme  :
      {
        "transactions":
        [
          {
            "label": "...",
            "category": "...",
            "amount": ...
          }
        ]
      }
    PROMPT
  end

  def parse_response(content)
    cleaned = content.gsub(/```json|```/, "").strip
    json = JSON.parse(cleaned, symbolize_names: true)
    { transactions: json[:transactions] || [] }
  end
end
