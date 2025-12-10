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
    @example_transactions = fetch_example_transactions
  end

  def llm_logger
    @llm_logger ||= Logger.new(Rails.root.join("log", "llm.log"))
  end

  def fetch_example_transactions
    # Récupère des exemples de transactions déjà catégorisées
    return [] if Expense.count.zero?

    Expense.joins(:category)
           .includes(:category)
           .order("RANDOM()")
           .limit(20)
           .map { |e| { label: e.label, category: e.category.name } }
  rescue StandardError => e
    llm_logger.warn("Impossible de récupérer les exemples: #{e.message}")
    []
  end

  def examples_list
    return "Aucun exemple disponible." if @example_transactions.empty?

    @example_transactions.map do |ex|
      "- \"#{ex[:label]}\" → #{ex[:category]}"
    end.join("\n")
  end

  def process
    models_to_try.each do |config|
      result = try_model(config[:model], config[:provider])
      return result if result[:transactions].any?
    end

    llm_logger.error("Tous les modèles ont échoué")
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
    llm_logger.info("Essai avec #{model} (#{provider})")
    llm_logger.info("Prompt:\n#{prompt}")

    chat = RubyLLM.chat(model: model, provider: provider)
    response = chat.ask(prompt)

    llm_logger.info("Response:\n#{response.content}")
    parse_response(response.content)
  rescue StandardError => e
    llm_logger.warn("#{model} échoué: #{e.message}")
    { total: nil, transactions: [] }
  end

  def prompt
    categories_list = @categories_with_keywords.map do |name, keywords|
      "- #{name} (ex: #{keywords})"
    end.join("\n")

    <<~PROMPT
      Tu es un expert en analyse de relevés bancaires français.

      RELEVÉ À ANALYSER :
      #{@text}

      CATÉGORIES DISPONIBLES :
      #{categories_list}

      EXEMPLES DE TRANSACTIONS DÉJÀ CATÉGORISÉES :
      #{examples_list}

      RÈGLES :
      1. Cherche d'abord les ARNAQUES : HPY, PDF, VERIF, BESTPDF
      2. Puis les assurances et abonnements identifiables (EDF, Orange, MAIF, AXA...)
      3. IGNORE tout le reste : achats (APPLE, CB), virements, salaires, transports (IDFM, UMS), abonnements inconnus (Starlink, Kindle)

      TOTAL : Cherche le montant total du relevé dans le PDF. Si introuvable, mets null.

      IMPORTANT : JSON uniquement, sans texte avant/après.
      Format : {"total": montant_ou_null, "transactions": [{"label": "...", "category": "...", "amount": ...}]}
    PROMPT
  end

  def parse_response(content)
    cleaned = content.gsub(/```json|```/, "").strip
    json = JSON.parse(cleaned, symbolize_names: true)

    valid_categories = Category.pluck(:name)
    valid_transactions = (json[:transactions] || []).select do |t|
      valid_categories.include?(t[:category])
    end

    { total: json[:total], transactions: valid_transactions }
  end
end
