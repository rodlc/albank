class LlmProcessor
  # Pipeline 3 étapes optimisé
  EXTRACTION_MODEL = "gemini-2.5-flash-lite"  # Étape 1: extraction rapide

  # Étape 3: Fallback multi-provider (Claude d'abord, meilleur JSON)
  CATEGORIZATION_MODELS = [
    { model: "anthropic/claude-3.5-sonnet", provider: :openrouter }, # OpenRouter - excellent reasoning + JSON
    { model: "gpt-4o", provider: :openai }                          # Azure/GitHub - fallback
  ].freeze

  CATEGORIZATION_TIMEOUT = 20 # secondes max pour l'étape 3

  def initialize
    @categories_with_keywords = Category.pluck(:name, :keywords)
  end

  def llm_logger
    @llm_logger ||= Logger.new(Rails.root.join("log", "llm.log"))
  end

  def process(file_path)
    # Étape 1: Extraction pure (toutes les transactions)
    raw_transactions = extract_transactions(file_path)
    return { total: nil, transactions: [], error: "Extraction échouée" } if raw_transactions.empty?

    # Étape 2: Catégorisation déterministe (keywords + historique)
    categorized = []
    orphans = []

    raw_transactions.each do |t|
      category = find_category_deterministic(t[:label])
      if category
        categorized << t.merge(category: category.name)
      else
        orphans << t
      end
    end

    llm_logger.info("📊 Étape 2 terminée: #{categorized.count} catégorisées, #{orphans.count} orphelins")

      # Étape 3: LLM intelligent pour orphelins (max 50 pour éviter truncation)
    pending_orphans = []
    if orphans.any?
      # Prioriser par montant décroissant, limiter à 50
      top_orphans = orphans.sort_by { |t| -t[:amount] }.first(50)
      remaining = orphans - top_orphans

      smart_results = categorize_orphans(top_orphans)
      if smart_results[:categorized].any?
        categorized.concat(smart_results[:categorized])
        enrich_keywords(smart_results[:new_mappings])
      end
      # Les non-catégorisés + ceux non envoyés = pending
      pending_orphans = remaining + (top_orphans - smart_results[:categorized].map { |c| top_orphans.find { |o| o[:label] == c[:label] } }.compact)
    end

    total = raw_transactions.sum { |t| t[:amount] }
    llm_logger.info("✅ Pipeline terminé: total=#{total}, #{categorized.count} catégorisées, #{pending_orphans.count} en attente")
    { total: total, transactions: categorized, pending_orphans: pending_orphans }
  end

  private

  # ==========================================
  # ÉTAPE 1: EXTRACTION PURE
  # ==========================================

  def extract_transactions(file_path)
    llm_logger.info("=" * 80)
    llm_logger.info("📄 Étape 1: Extraction avec #{EXTRACTION_MODEL}")
    llm_logger.info("=" * 80)

    chat = RubyLLM.chat(model: EXTRACTION_MODEL, provider: :gemini)
    response = chat.ask(extraction_prompt, with: file_path)

    llm_logger.info("✅ Réponse reçue (#{response.content.length} chars)")
    llm_logger.info("Response:\n#{response.content}")

    transactions = parse_extraction_response(response.content)
    llm_logger.info("📊 #{transactions.count} transactions extraites")
    transactions
  rescue StandardError => e
    llm_logger.error("❌ Extraction échouée: #{e.class} - #{e.message}")
    llm_logger.error(e.backtrace.first(5).join("\n"))
    []
  end

  def extraction_prompt
    <<~PROMPT
      Extrais TOUTES les transactions de ce relevé bancaire français.

      Pour chaque transaction, retourne :
      - label : libellé complet tel qu'affiché
      - amount : montant en nombre décimal (ex: 21.61)
      - date : date au format DD/MM si visible

      INCLUS TOUT : prélèvements, CB, virements, etc.

      EXCLUS :
      - Lignes comptables (solde créditeur, solde débiteur, totaux)
      - Lignes récapitulatives

      FORMAT JSON UNIQUEMENT :
      {"total": montant_total_débits, "transactions": [{"label": "...", "amount": 123.45, "date": "01/12"}]}
    PROMPT
  end

  def parse_extraction_response(content)
    json = extract_json(content)
    return [] unless json

    (json[:transactions] || []).map do |t|
      { label: t[:label], amount: t[:amount].to_f.abs, date: t[:date] }
    end
  rescue StandardError => e
    llm_logger.error("❌ Parsing extraction échoué: #{e.message}")
    []
  end

  # ==========================================
  # ÉTAPE 2: CATÉGORISATION DÉTERMINISTE
  # ==========================================

  def find_category_deterministic(label)
    normalized = normalize_label(label)

    # 1. Chercher dans l'historique des expenses
    existing = Expense.joins(:category)
                      .where("UPPER(label) LIKE ?", "%#{normalized}%")
                      .first
    if existing
      llm_logger.debug("🔍 Historique trouvé: '#{label}' → #{existing.category.name}")
      return existing.category
    end

    # 2. Matcher contre les keywords des catégories
    Category.find_each do |cat|
      keywords = cat.keywords.to_s.downcase.split(/\s+/)
      matched_kw = keywords.find { |kw| normalized.downcase.include?(kw) && kw.length > 2 }
      if matched_kw
        llm_logger.debug("🔑 Keyword trouvé: '#{label}' → #{cat.name} (keyword: #{matched_kw})")
        return cat
      end
    end

    llm_logger.debug("❓ Orphelin: '#{label}'")
    nil
  end

  def normalize_label(label)
    label.gsub(/PRLV SEPA|CARTE \d{2}\/\d{2}|VIR INST/i, "")
         .gsub(/\d{2}\/\d{2}/, "")
         .gsub(/\d{10,}/, "")
         .gsub(/Numéro de (client|compte).*$/i, "")
         .strip
         .split(/\s+/).take(3).join(" ")
         .upcase
  end

  # ==========================================
  # ÉTAPE 3: LLM INTELLIGENT POUR ORPHELINS
  # ==========================================

  def categorize_orphans(orphans)
    CATEGORIZATION_MODELS.each do |config|
      model_name = config[:model]
      provider = config[:provider]

      llm_logger.info("=" * 80)
      llm_logger.info("🧠 Étape 3: #{orphans.count} orphelins → #{model_name} (#{provider}, timeout #{CATEGORIZATION_TIMEOUT}s)")
      llm_logger.info("=" * 80)

      begin
        chat = RubyLLM.chat(model: model_name, provider: provider)
        response = chat.ask(orphans_prompt(orphans))

        llm_logger.info("✅ Réponse reçue (#{response.content.length} chars)")
        llm_logger.info("Response:\n#{response.content}")

        return parse_orphans_response(response.content, orphans)
      rescue StandardError => e
        llm_logger.warn("⚠️ #{model_name} échoué: #{e.class} - #{e.message}")
        next
      end
    end

    llm_logger.warn("⚠️ Tous les modèles ont échoué → orphelins stockés pour plus tard")
    { categorized: [], new_mappings: [] }
  end

  def orphans_prompt(orphans)
    categories_list = Category.pluck(:name, :keywords).map do |name, kw|
      "#{name}: #{kw}"
    end.join("\n")

    # Format compact: numéro=libellé
    orphans_list = orphans.each_with_index.map { |t, i| "#{i}=#{t[:label]}" }.join("\n")

    <<~PROMPT
      Tu es un expert en catégorisation de prélèvements bancaires français.

      CATÉGORIES DISPONIBLES:
      #{categories_list}

      TRANSACTIONS À ANALYSER:
      #{orphans_list}

      RÈGLES:
      - PRLV SEPA = prélèvement automatique récurrent, TOUJOURS chercher une catégorie
      - Ignore: VIR (virements), RET DAB (retraits), CARTE (achats CB ponctuels)
      - Match partiel OK: "ULYS MOBILITE" → mobilité → Assurance Trottinette
      - Assureurs connus: ALAN, LUKO, LOVYS, LEOCARE → Mutuelle ou Assurance

      FORMAT (une ligne par match trouvé):
      numéro|Catégorie exacte|keyword

      Exemple:
      4|Assurance Trottinette|mobilite
      12|Mutuelle Santé|alan
    PROMPT
  end

  def parse_orphans_response(content, orphans)
    valid_categories = Category.pluck(:name)
    categorized = []
    new_mappings = []

    # Parse format: numéro|Catégorie|keyword
    content.each_line do |line|
      line = line.strip
      next if line.empty? || line.start_with?("#") || line.start_with?("Exemple")

      parts = line.split("|").map(&:strip)
      next unless parts.length >= 2

      idx = parts[0].to_i
      category_name = parts[1]
      keyword = parts[2]

      next unless valid_categories.include?(category_name)
      next if idx < 0 || idx >= orphans.length

      original = orphans[idx]
      next unless original

      categorized << original.merge(category: category_name)

      if keyword && keyword.length >= 3
        new_mappings << { category: category_name, keyword: keyword }
      end
    end

    llm_logger.info("✅ #{categorized.count} orphelins catégorisés, #{new_mappings.count} keywords détectés")
    { categorized: categorized, new_mappings: new_mappings }
  rescue StandardError => e
    llm_logger.error("❌ Parsing orphans échoué: #{e.message}")
    { categorized: [], new_mappings: [] }
  end

  def enrich_keywords(new_mappings)
    new_mappings.each do |mapping|
      category = Category.find_by(name: mapping[:category])
      next unless category

      keyword = mapping[:keyword].to_s.downcase.strip
      next if keyword.blank? || keyword.length < 3
      next if category.keywords.to_s.downcase.include?(keyword)

      category.update!(keywords: "#{category.keywords} #{keyword}".strip)
      llm_logger.info("✨ Keyword ajouté: '#{keyword}' → #{category.name}")
    end
  end

  # ==========================================
  # HELPERS
  # ==========================================

  def extract_json(content)
    start_idx = content.index("{")
    unless start_idx
      llm_logger.error("❌ Aucun JSON trouvé dans la réponse")
      return nil
    end

    # Balancer les accolades pour trouver la fin de l'objet JSON
    depth = 0
    end_idx = start_idx
    content[start_idx..].each_char.with_index(start_idx) do |char, idx|
      depth += 1 if char == "{"
      depth -= 1 if char == "}"
      if depth.zero?
        end_idx = idx
        break
      end
    end

    json_str = content[start_idx..end_idx]

    # Fix common JSON issues from LLMs
    json_str = fix_json(json_str)

    JSON.parse(json_str, symbolize_names: true)
  rescue JSON::ParserError => e
    llm_logger.error("❌ JSON parsing failed: #{e.message}")
    nil
  end

  def fix_json(json_str)
    # Remove trailing commas before ] or }
    json_str.gsub(/,(\s*[\]\}])/, '\1')
  end

end
