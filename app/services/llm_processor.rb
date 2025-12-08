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

    PROMPT

    response = @client.chat()

  end
end
