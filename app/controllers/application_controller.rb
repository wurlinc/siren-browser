class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from OAuth2::Error do |exception|
    if exception.response.status == 401
      session[:user_id] = nil
      session[:access_token] = nil
      redirect_to root_url, alert: "Access token expired, try signing in again."
    end
  end

  def index

  end

  def get_data
    url = params[:url]
    unless params.has_key?(:url)
      Rails.logger.error("url parameter not set")
      render :text => "Bad Request", :status => 400 and return
    end

    if current_user
      json = access_token.get(url_path(url)).parsed
    else
      c = Curl::Easy.new(params[:url])
      c.perform
      if c.response_code != 200
        Rails.logger.error("There was a problem getting #{url}: status #{c.response_code}, response: #{c.body_str}")
        render :text=> c.body_str, :status => c.response_code and return
      end
      json = ActiveSupport::JSON.decode(c.body_str)
    end
    Rails.logger.debug(json)
    render :json=> json
  end

  private

  def url_path(url)
    uri = URI.parse(url)
    if uri.port.nil? || uri.port == 80
      base_url = "#{uri.scheme}://#{uri.host}"
    else
      base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
    end
    url.slice!(base_url)
    url
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(WurlOauthProvider.app_id, WurlOauthProvider.app_secret, site: WurlOauthProvider.host)
  end

  def access_token
    if session[:access_token]
      @access_token ||= OAuth2::AccessToken.new(oauth_client, session[:access_token])
    end
  end

  def current_user
    @current_user ||= session[:user_data]
  end
  helper_method :current_user
end
