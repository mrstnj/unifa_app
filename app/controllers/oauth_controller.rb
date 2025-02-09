require 'net/http'

class OauthController < ApplicationController
  def authorize
    request_url = 'http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/authorize'
    query_params = {
      client_id: Rails.application.credentials.oauth[:client_id],
      redirect_uri: 'http://localhost:3000/oauth/callback',
      response_type: 'code',
      scope: 'write_tweet',
    }

    redirect_to "#{request_url}?#{query_params.to_query}", allow_other_host: true
  end

  def callback
    request_url = 'http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/token'
    query_params = {
      client_id: Rails.application.credentials.oauth[:client_id],
      client_secret: Rails.application.credentials.oauth[:client_secret],
      redirect_uri: 'http://localhost:3000/oauth/callback',
      grant_type: 'authorization_code',
      code: params[:code],
    }

    uri = URI.parse(request_url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(query_params)
    response = http.request(request)
    session[:oauth_access_token] = JSON.parse(response.body)['access_token']

    redirect_to user_images_path
  end
end

