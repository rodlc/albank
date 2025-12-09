RubyLLM.configure do |config|
  config.openai_api_key = ENV['GITHUB_TOKEN']
  config.openai_api_base = ENV['OPENAI_API_BASE']
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
  config.gemini_api_key = ENV['GEMINI_API_KEY']

  # New apps: Use modern API (generator adds this)
  # config.use_new_acts_as = true

  # For custom Model class names (defaults to 'Model')
  # config.model_registry_class = 'AIModel'
end
