class UserImagesController < ApplicationController
  def new
    @image = UserImage.new
  end

  def create
    @image = UserImage.new(image_params)
    @image.user = @current_user
    if @image.save!
      flash[:notice] = "画像がアップロードされました！"
      redirect_to user_images_path
    else
      flash[:alert] = "アップロードに失敗しました。"
      render :new
    end
  end

  def index
    @images = UserImage.all
  end

  private

  def image_params
    params.require(:user_image).permit(:title, :image)
  end
end
