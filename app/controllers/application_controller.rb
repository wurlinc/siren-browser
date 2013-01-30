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

    c = Curl::Easy.new(params[:url])
    c.perform
    if c.response_code != 200
      Rails.logger.error("There was a problem getting #{url}: status #{c.response_code}, response: #{c.body_str}")
      render :text=> c.body_str, :status => c.response_code and return
    end
    json = ActiveSupport::JSON.decode(c.body_str)
    Rails.logger.debug(json)
    render :json=> json
  end

  private

  def oauth_client
    Rails.logger.debug(APP_CONFIG['oauth_host'])
    @oauth_client ||= OAuth2::Client.new(ENV["OAUTH_ID"], ENV["OAUTH_SECRET"], site: APP_CONFIG['oauth_host'])
  end

  def access_token
    if session[:access_token]
      @access_token ||= OAuth2::AccessToken.new(oauth_client, session[:access_token])
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
