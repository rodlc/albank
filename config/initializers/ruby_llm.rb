RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
  config.gemini_api_key = ENV['GEMINI_API_KEY']

  # New apps: Use modern API (generator adds this)
  # config.use_new_acts_as = true

  # For custom Model class names (defaults to 'Model')
  # config.model_registry_class = 'AIModel'
end
