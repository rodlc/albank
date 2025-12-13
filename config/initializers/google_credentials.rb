if ENV['GOOGLE_CREDENTIALS_BASE64'].present?
  require 'base64'
  credentials_json = Base64.decode64(ENV['GOOGLE_CREDENTIALS_BASE64'])
  credentials_path = Rails.root.join('tmp', 'google_credentials.json')
  File.write(credentials_path, credentials_json)
  ENV['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path.to_s
end
