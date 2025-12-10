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
Tu es un **Expert-Comptable Senior** spécialisé dans l'**analyse des relevés bancaires de particuliers français**
et l'**identification des frais potentiellement excessifs**. Ton rôle est de fournir une analyse extrêmement précise et fiable.

**1. DONNÉES À ANALYSER (Relevé Client) :**
---
RELEVÉ BRUT :
#{@text}

**2. CATALOGUE DE CATÉGORIES (Le Stock de la Boutique) :**
---
Voici la liste des catégories de dépenses connues (avec des mots-clés typiques pour t'aider) :
#{categories_list}

**3. MISSION PRINCIPALE (Le Service Client) :**
---
Pour **chaque transaction** dans le RELEVÉ BRUT, tu dois effectuer deux actions essentielles :
a) **Catégorisation Rigoureuse :** Identifier la **catégorie** la plus pertinente pour chaque libellé. Fais preuve de jugement même si le libellé est tronqué ou inhabituel.
b) **Détection d'Alertes :** Identifier si la transaction représente un **frais bancaire** ou une **dépense récurrente suspecte** (comme un abonnement potentiel non souhaité). Ajoute une alerte (`"is_fee": true` ou `"is_alert": true`) si tu as une forte suspicion d'un frais bancaire ou d'un abonnement difficile à annuler, **en particulier** dans la catégorie "Frais Bancaires".

**4. LIVRABLE ATTENDU (Le Bon de Commande Final) :**
---
Tu dois **STRICTEMENT** retourner le résultat au format **JSON**, et ce JSON doit être le seul et unique contenu de ta réponse.

Format JSON requis :
{
  "total_depenses": Montant_Total_des_dépenses_uniquement,
  "transactions": [
    {
      "label": "Libellé original exact",
      "category": "Catégorie déduite",
      "amount": Montant numérique (toujours négatif pour les dépenses, positif pour les revenus),
      "is_fee": true/false,  // Vrai si c'est un frais bancaire clair (ex: Agio, frais de tenue de compte, commission)
      "is_alert": true/false // Vrai si c'est un abonnement potentiel suspect ou un frais inhabituel
    }
    // ... autres transactions
  ]
}
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
