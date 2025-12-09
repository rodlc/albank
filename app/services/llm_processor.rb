require 'openai'  # gem 'ruby-openai' dans ton Gemfile

class LlmProcessor
  def initialize(libelle, montant)
    @libelle = libelle
    @montant = montant
    @client = OpenAI::Client.new
  end

  def process
    # Simuler un appel à un LLM pour enrichir les données
    prompt = <<~PROMPT
      Catégorise la dépense suivante et enrichis le libellé.
      Libellé: #{@libelle}
      Montant: #{@montant}

      Reformule le libellé en clair et attribue une catégorie parmi :
      - energie
      - internet
      - auto
      - habitation
      - banque
      - autres

      Réponds uniquement en JSON avec les clés :
      {
        "libelle": "...",
        "categorie": "...",
        "montant": ...
      }

    PROMPT

  response = LLM.call(prompt)
  t[:libelle_clair] = response[:libelle]
  t[:category] = response[:category]

    # A faire !!
  end
end
