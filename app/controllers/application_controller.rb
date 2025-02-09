class ApplicationController < ActionController::Base
  before_action :authenticate_token

  protected

  def authenticate_token
    auth_token = session[:access_token]
    if auth_token.present?
      user = User.find_by(access_token: auth_token)
      if user.present? && Time.now <= user.access_token_expire_date
        user.access_token_expire_date = 30.minutes.from_now
        user.save
        @current_user = user
      else
        flash[:alert] = '認証エラーです。ログインし直してください。'
        redirect_to login_path
      end
    else
      flash[:alert] = '認証エラーです。ログインし直してください。'
      redirect_to login_path
    end
  end
end
