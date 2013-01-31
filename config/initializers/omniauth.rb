require File.expand_path('lib/omniauth/strategies/wurl', Rails.root)

Rails.application.config.middleware.use OmniAuth::Builder do
  begin
    provider :wurl, WurlOauthProvider.app_id, WurlOauthProvider.app_secret
    OmniAuth.config.logger = Rails.logger
  rescue => e
    Rails.logger.error("Could not initialize omniauth")
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
  end
end
