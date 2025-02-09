class UserImagesController < ApplicationController
  def new
    @image = UserImage.new
  end

  def create
    error_messages = []

    @image = UserImage.new(image_params)
    @image.user = @current_user
    if @image.save
      redirect_to user_images_path
    else
      error_messages.concat(@image.errors.map { |error| error.options[:message] })
    end

    set_flash_and_redirect(error_messages, new_user_image_path) if error_messages.any?
  end

  def index
    @images = UserImage.all
  end

  private

  def image_params
    params.require(:user_image).permit(:title, :image)
  end
end
