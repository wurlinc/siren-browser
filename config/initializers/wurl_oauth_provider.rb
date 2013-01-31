class WurlOauthProvider
  cattr_accessor :app_id
  cattr_accessor :app_secret
  cattr_accessor :host
end

config_file = File.join(Rails.root, "config", "omniauth.yml")
WurlOauthProvider.app_id = YAML.load_file(config_file)[Rails.env]['app_id']
WurlOauthProvider.app_secret = YAML.load_file(config_file)[Rails.env]['app_secret']
WurlOauthProvider.host = YAML.load_file(config_file)[Rails.env]['oauth_host']
