class SessionController < ApplicationController
  skip_before_action :authenticate_token, only: [:new, :create]

  def create
    error_messages = []
    error_messages << 'ログインIDを入力してください' if params[:login].blank?
    error_messages << 'パスワードを入力してください' if params[:password].blank?

    @user = User.authenticate(params[:login], params[:password])
    if @user.present?
      reset_session
      @user.issue_access_token
      session[:access_token] = @user.access_token
      redirect_to user_images_path
    else
      error_messages << 'ログインIDまたはパスワードが正しくありません'
    end

    if error_messages.any?
      flash[:alert] = error_messages.join(', ')
      redirect_to login_path
    end
  end

end
