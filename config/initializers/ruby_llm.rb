RubyLLM.configure do |config|
  # Google Vertex AI (primary) - remplace AI Studio
  config.vertexai_project_id = ENV['GOOGLE_CLOUD_PROJECT']
  config.vertexai_location = ENV.fetch('GOOGLE_CLOUD_LOCATION', 'us-central1')

  # Meta Llama via OpenRouter (fallback)
  config.openrouter_api_key = ENV['OPENROUTER_API_KEY']

  # Azure OpenAI GPT-4o (last resort)
  config.openai_api_key = ENV['GITHUB_API_KEY']
  config.openai_api_base = "https://models.inference.ai.azure.com"
end
