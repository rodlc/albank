class LlmProcessor
  def initialize(text)
    @text = text
    @chat = RubyLLM.chat(model: ENV["GITHUB_MODEL"])
  end

  def process
    prompt = <<~PROMPT
    Voici le contenu de mon relevé bancaire :
      #{@text}

      Catégorise les dépenses suivantes et enrichis chaque libellé.

      Attribue une catégorie parmi :
      #{Category.pluck(:name).join(", ")}

      Réponds uniquement en JSON avec les clés, en reprenant toutes les lignes de dépenses, avec cette forme  :
      {
        "transactions":
        [
          {
            "label": "...",
            "category": "...",
            "amount": ...
          },
          {
            "label": "...",
            "category": "...",
            "amount": ...
          }
        ]
      }
    PROMPT

    response = @chat.ask(prompt)
    parse_response(response.content)
  rescue JSON::ParserError
    Rails.logger.warn("[LLM] JSON invalide, retry...")
    retry_response = @chat.ask("#{prompt}\n\nIMPORTANT: Réponds UNIQUEMENT en JSON valide.")
    parse_response(retry_response.content)
  rescue JSON::ParserError => e
    Rails.logger.error("[LLM] Échec après retry: #{e.message}")
    { transactions: [] }
  end

  private

  def parse_response(content)
    cleaned = content.gsub(/```json|```/, "").strip
    json = JSON.parse(cleaned, symbolize_names: true)
    { transactions: json[:transactions] || [] }
  end
end
