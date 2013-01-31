class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    session[:user_id] = auth["uid"]
    session[:access_token] = auth["credentials"]["token"]
    session[:user_data] = access_token.get('/api/user').parsed
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil
    session[:user_data] = nil
    redirect_to root_url
  end

  def failure
    #TODO:
    # http://stackoverflow.com/questions/10737200/how-to-rescue-omniauthstrategiesoauth2callbackerror
  end
end
