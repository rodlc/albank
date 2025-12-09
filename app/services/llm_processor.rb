require 'openai'  # gem 'ruby-openai' dans ton Gemfile

class LlmProcessor
  def initialize(text)
    @text = text
    @chat =  RubyLLM.chat(model: "gpt-4o")
  end

  def process
    # Simuler un appel à un LLM pour enrichir les données
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

    response = @chat.ask prompt

    content = response.content.gsub("```json", "").gsub("```", "").strip
    json = JSON.parse(content, symbolize_names: true)
    data = { transactions: json[:transactions] || [] }

    puts "[LLM CLEANED RESPONSE] #{data}"

    return data
  end
end
