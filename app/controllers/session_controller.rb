class SessionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
  end

  def create
    @user = User.authenticate(params[:login], params[:password])
    if @user.present?
      @user.issue_access_token
      render json: { "message": "OK" }
    else
      render json: { error: "Invalid login or password" }, status: :unauthorized
    end
  end

end
