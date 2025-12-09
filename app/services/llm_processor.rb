class LlmProcessor
  # Triumvirat de résilience : Google → Meta → Microsoft
  FALLBACK_MODELS = [
    # Google Gemini (primary, GCP credits)
    { model: "gemini-flash-lite-latest", provider: :gemini },  # Rapide & économique
    { model: "gemini-flash-latest", provider: :gemini },       # Intelligent

    # Meta Llama (fallback, OpenRouter free tier)
    { model: "meta-llama/llama-3.3-70b-instruct:free", provider: :openrouter },

    # Azure OpenAI (last resort, GitHub Models)
    { model: "gpt-4o", provider: :openai },
  ].freeze

  def initialize(text)
    @text = text
    @categories = Category.pluck(:name)
  end

  def process
    models_to_try.each do |config|
      result = try_model(config[:model], config[:provider])
      return result if result[:transactions].any?
    end

    Rails.logger.error("[LLM] Tous les modèles ont échoué")
    { transactions: [] }
  end

  private

  def models_to_try
    if ENV["LLM_MODEL"]
      [{ model: ENV["LLM_MODEL"], provider: :gemini }] + FALLBACK_MODELS
    else
      FALLBACK_MODELS
    end
  end

  def try_model(model, provider)
    Rails.logger.info("[LLM] Essai avec #{model} (#{provider})")
    chat = RubyLLM.chat(model: model, provider: provider)
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
