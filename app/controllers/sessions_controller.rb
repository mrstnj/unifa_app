class SessionsController < ApplicationController
  skip_before_action :authenticate_token, only: [:new, :create]

  def create
    error_messages = []
    error_messages << 'ログインIDを入力してください' if params[:login].blank?
    error_messages << 'パスワードを入力してください' if params[:password].blank?

    begin
      @user = User.authenticate_with_lock(params[:login], params[:password])
      if @user.present?
        reset_session
        @user.issue_access_token
        session[:access_token] = @user.access_token
        redirect_to user_images_path
      else
        error_messages << 'ログインIDまたはパスワードが正しくありません'
      end
    rescue Exceptions::LockedError
      error_messages << 'アカウントをロックしました'
    end

    set_flash_and_redirect(error_messages, login_path) if error_messages.any?
  end

  def destroy
    reset_session
    redirect_to login_path
  end

end
