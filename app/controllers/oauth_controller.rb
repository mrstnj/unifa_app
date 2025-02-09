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
  end
end
