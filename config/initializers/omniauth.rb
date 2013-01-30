require File.expand_path('lib/omniauth/strategies/wurl', Rails.root)

Rails.application.config.middleware.use OmniAuth::Builder do
  begin
    omniauth_config = HashWithIndifferentAccess.new(YAML.load(File.open("#{Rails.root}/config/omniauth.yml")))
    app_id = omniauth_config[Rails.env][:app_id]
    app_secret = omniauth_config[Rails.env][:app_secret]

    provider :wurl, app_id, app_secret

    OmniAuth.config.logger = Rails.logger

  rescue => e
    Rails.logger.error("Could not initialize omniauth")
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
  end
end
