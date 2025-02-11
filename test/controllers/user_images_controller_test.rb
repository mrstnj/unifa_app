require "test_helper"

class UserImagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @valid_image = fixture_file_upload('test/fixtures/files/valid_image.jpg', 'image/jpeg')
    @large_image = fixture_file_upload('test/fixtures/files/large_image.png', 'image/png')
    @invalid_type_image = fixture_file_upload('test/fixtures/files/invalid.txt', 'text/plain')
    
    # ログイン状態を作成
    @user.update!(password: "Password123!")  # 一時的にパスワードを設定
    post login_path, params: { login: @user.login, password: "Password123!" }
  end

  test "should get index" do
    get user_images_path
    assert_response :success
  end

  test "should get new" do
    get new_user_image_path
    assert_response :success
  end

  test "should create user_image with valid params" do
    assert_difference('UserImage.count') do
      post user_images_path, params: {
        user_image: {
          title: "Test Image",
          image: @valid_image
        }
      }
    end

    assert_redirected_to user_images_path
  end

  test "should not create user_image with invalid params" do
    assert_no_difference('UserImage.count') do
      post user_images_path, params: {
        user_image: {
          title: "",  # タイトルなし
          image: @valid_image
        }
      }
    end

    assert_response :found
  end

  test "should not create user_image with large image" do
    assert_no_difference('UserImage.count') do
      post user_images_path, params: {
        user_image: {
          title: "Large Image",
          image: @large_image
        }
      }
    end

    assert_response :found
  end

  test "should not create user_image with invalid file type" do
    assert_no_difference('UserImage.count') do
      post user_images_path, params: {
        user_image: {
          title: "Invalid Type",
          image: @invalid_type_image
        }
      }
    end

    assert_response :found
  end

  test "should tweet image" do
    image = UserImage.create!(
      title: "Test Image",
      user: @user,
      image: @valid_image
    )

    session[:oauth_access_token] = "test_token"

    Net::HTTP.stub :new, mock_http(201) do
      post user_images_tweet_path, params: { image_id: image.id }
      assert_redirected_to user_images_path
      assert_equal 'ツイートしました', flash[:notice]
    end
  end

  test "should handle tweet failure" do
    image = UserImage.create!(
      title: "Test Image",
      user: @user,
      image: @valid_image
    )

    session[:oauth_access_token] = "test_token"

    Net::HTTP.stub :new, mock_http(500) do
      post user_images_tweet_path, params: { image_id: image.id }
      assert_redirected_to user_images_path
      assert_equal 'ツイートに失敗しました', flash[:alert]
    end
  end

  test "should require authentication" do
    delete logout_path
    get user_images_path
    assert_redirected_to login_path
  end

  private

  def mock_http(status)
    mock = Minitest::Mock.new
    response = case status
      when 201
        Net::HTTPSuccess.new(1.0, status, "")
      else
        Net::HTTPResponse.new(1.0, status, "")
      end
    mock.expect :request, response do |request|
      request.is_a?(Net::HTTP::Post)
    end
    mock
  end
end
