class SessionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    error_messages = []
    error_messages << 'ログインIDを入力してください' if params[:login].blank?
    error_messages << 'パスワードを入力してください' if params[:password].blank?

    @user = User.authenticate(params[:login], params[:password])
    if @user.present?
      @user.issue_access_token
      render json: { "message": "OK" }
    else
      error_messages << 'ログインIDまたはパスワードが正しくありません'
    end

    if error_messages.any?
      flash[:alert] = error_messages.join(', ')
      redirect_to login_path
    end
  end

end
