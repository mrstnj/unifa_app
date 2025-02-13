require "test_helper"

class OauthControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user.update!(password: "Password123!")
    post login_path, params: { login: @user.login, password: "Password123!" }
  end

  test "should redirect to oauth authorize url" do
    get oauth_authorize_path
    assert_response :redirect
    
    redirect_uri = URI.parse(@response.redirect_url)
    params = Rack::Utils.parse_query(redirect_uri.query)
    
    assert_equal OauthController::OAUTH_BASE_URL, "#{redirect_uri.scheme}://#{redirect_uri.host}"
    assert_equal Rails.application.credentials.oauth[:client_id], params["client_id"]
    assert_equal oauth_callback_url, params["redirect_uri"]
    assert_equal "code", params["response_type"]
    assert_equal "write_tweet", params["scope"]
  end

  test "should handle successful oauth callback" do
    mock_token_response = {
      "access_token" => "test_access_token"
    }.to_json

    stub_request = Struct.new(:response) do
      def request(req)
        response
      end
    end

    mock_response = Struct.new(:body) do
      def is_a?(klass)
        klass == Net::HTTPSuccess
      end
    end.new(mock_token_response)

    Net::HTTP.stub :new, stub_request.new(mock_response) do
      get oauth_callback_path, params: { code: "test_code" }
      
      assert_redirected_to user_images_path
      assert_equal "認証に成功しました", flash[:notice]
      assert_equal "test_access_token", session[:oauth_access_token]
    end
  end

  test "should handle oauth callback failure" do
    stub_request = Struct.new(:response) do
      def request(req)
        response
      end
    end

    mock_response = Struct.new(:body) do
      def is_a?(klass)
        false
      end
    end.new("")

    Net::HTTP.stub :new, stub_request.new(mock_response) do
      get oauth_callback_path, params: { code: "invalid_code" }
      
      assert_redirected_to user_images_path
      assert_equal "認証に失敗しました", flash[:alert]
      assert_nil session[:oauth_access_token]
    end
  end

  test "should handle oauth callback network error" do
    Net::HTTP.stub :new, ->(*args) { 
      mock = Minitest::Mock.new
      mock.expect :request, ->(request) { raise StandardError.new("Network error") } 
      mock
    } do
      get oauth_callback_path, params: { code: "test_code" }
      
      assert_equal "認証中にエラーが発生しました", flash[:alert]
      assert_redirected_to user_images_path
      assert_nil session[:oauth_access_token]
    end
  end
end
