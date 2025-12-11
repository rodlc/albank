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
    @categories_with_keywords = Category.pluck(:name, :keywords)
  end

  def process
    models_to_try.each do |config|
      result = try_model(config[:model], config[:provider])
      return result if result[:transactions].any?
    end

    Rails.logger.error("[LLM] Tous les modèles ont échoué")
    { total: nil, transactions: [] }
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
    Rails.logger.info("[LLM] Prompt: #{prompt.truncate(500)}")

    chat = RubyLLM.chat(model: model, provider: provider)
    response = chat.ask(prompt)

    Rails.logger.info("[LLM] Response: #{response.content.truncate(1000)}")
    parse_response(response.content)
  rescue StandardError => e
    Rails.logger.warn("[LLM] #{model} échoué: #{e.message}")
    { total: nil, transactions: [] }
  end

  def prompt
    categories_list = @categories_with_keywords.map do |name, keywords|
      "- #{name} (ex: #{keywords})"
    end.join("\n")

    <<~PROMPT
      Tu es un expert en analyse de relevés bancaires français.

      RELEVÉ :
      #{@text}

      CATÉGORIES CONNUES (avec exemples de mots-clés) :
      #{categories_list}

      MISSION :
      Pour chaque ligne du relevé, identifie :
      - Le libellé original (tel qu'il apparaît)
      - La catégorie la plus probable
      - Le montant

      Les mots-clés sont des indices, pas des règles strictes.
      Utilise ton intelligence pour déduire la catégorie même si le libellé est abrégé ou cryptique.

      Extrais aussi :
      - La date du relevé (mois/année de la période couverte, au format YYYY-MM-DD avec le 1er du mois)
      - Le total des dépenses (débits uniquement, en valeur absolue)

      IMPORTANT : Réponds UNIQUEMENT avec le JSON, sans aucun texte avant ou après.
      Format : {"statement_date": "YYYY-MM-DD", "total": montant_total, "transactions": [{"label": "...", "category": "...", "amount": ...}]}
    PROMPT
  end

  def parse_response(content)
    cleaned = content.gsub(/```json|```/, "").strip
    json = JSON.parse(cleaned, symbolize_names: true)

    valid_categories = Category.pluck(:name)
    valid_transactions = (json[:transactions] || []).select do |t|
      valid_categories.include?(t[:category])
    end

    { statement_date: json[:statement_date], total: json[:total], transactions: valid_transactions }
  end
end
