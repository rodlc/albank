RubyLLM.configure do |config|
  # Google Gemini (primary)
  config.gemini_api_key = ENV['GEMINI_API_KEY']

  # Meta Llama via OpenRouter (fallback)
  config.openrouter_api_key = ENV['OPENROUTER_API_KEY']

  # Azure OpenAI GPT-4o (last resort)
  config.openai_api_key = ENV['GITHUB_API_KEY']
  config.openai_api_base = "https://models.inference.ai.azure.com"
end
