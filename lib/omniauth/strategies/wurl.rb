module OmniAuth
  module Strategies
    class Wurl < OmniAuth::Strategies::OAuth2
      option :name, :wurl

      config_file = File.join(Rails.root, "config", "omniauth.yml")
      host = YAML.load_file(config_file)[Rails.env]['oauth_host']

      option :client_options, {
          site: host,
          authorize_path: "/oauth/authorize"
      }

      uid do
        raw_info["id"]
      end

      info do
        {name: raw_info["first"]}
      end

      def raw_info
        @raw_info ||= access_token.get('/api/user').parsed
        Rails.logger.debug('user info:' + @raw_info.to_s)
        @raw_info
      end
    end
  end
end
