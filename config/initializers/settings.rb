Rails.application.configure do
  # Slack Settings
  config.x.slack.client_id = Rails.application.credentials.slack.client_id
  config.x.slack.client_secret = Rails.application.credentials.slack.client_secret
  config.x.slack.signing_secret = Rails.application.credentials.slack.signing_secret
  config.x.slack.verification_token = Rails.application.credentials.slack.verification_token
  config.x.slack.oauth_scope = JSON.parse(File.read("slack-app-manifest.json")).dig("oauth_config", "scopes", "bot").join(",")
end
