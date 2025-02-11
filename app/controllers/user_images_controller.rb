class UserImagesController < ApplicationController
  TWEET_API_URL = 'http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/api/tweets'

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
    @images = UserImage.where(user: @current_user).order(created_at: :desc)
  end

  def tweet
    image = UserImage.find(params[:image_id])
    image_url = url_for(image.image)
    request_body = {
      text: image.title.strip,
      url: image_url
    }.to_json

    uri = URI(TWEET_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(
      uri.path,
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{session[:oauth_access_token]}"
    )
    request.body = request_body

    begin
      response = http.request(request)
      
      if response.is_a?(Net::HTTPSuccess)
        flash[:notice] = 'ツイートしました'
      else
        flash[:alert] = 'ツイートに失敗しました'
      end
    rescue => e
      Rails.logger.error "Tweet error: #{e.message}"
      flash[:alert] = 'エラーが発生しました'
    end
    
    redirect_to user_images_path
  end

  private

  def image_params
    params.require(:user_image).permit(:title, :image)
  end
end
