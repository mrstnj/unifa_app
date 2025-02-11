require 'net/http'

class OauthController < ApplicationController
  OAUTH_BASE_URL = 'http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com'

  def authorize
    request_url = "#{OAUTH_BASE_URL}/oauth/authorize"
    query_params = {
      client_id: Rails.application.credentials.oauth[:client_id],
      redirect_uri: oauth_callback_url,
      response_type: 'code',
      scope: 'write_tweet',
    }

    redirect_to "#{request_url}?#{query_params.to_query}", allow_other_host: true
  end

  def callback
    request_url = "#{OAUTH_BASE_URL}/oauth/token"
    query_params = {
      client_id: Rails.application.credentials.oauth[:client_id],
      client_secret: Rails.application.credentials.oauth[:client_secret],
      redirect_uri: oauth_callback_url,
      grant_type: 'authorization_code',
      code: params[:code],
    }

    uri = URI.parse(request_url)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request.set_form_data(query_params)

    begin
      response = http.request(request)
      
      if response.is_a?(Net::HTTPSuccess)
        session[:oauth_access_token] = JSON.parse(response.body)['access_token']
        flash[:notice] = '認証に成功しました'
      else
        flash[:alert] = '認証に失敗しました'
      end
    rescue => e
      Rails.logger.error "OAuth error: #{e.message}"
      flash[:alert] = '認証中にエラーが発生しました'
    end

    redirect_to user_images_path
  end
end