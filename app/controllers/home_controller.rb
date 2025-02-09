class HomeController < ApplicationController
  def index
    if @current_user
      redirect_to user_images_path
    else
      redirect_to login_path
    end
  end
end 