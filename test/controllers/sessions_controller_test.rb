require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user.update!(password: "Password123!")
  end

  test "should get login page" do
    get login_path
    assert_response :success
  end

  test "should login with valid credentials" do
    post login_path, params: { login: @user.login, password: "Password123!" }
    assert_redirected_to user_images_path
    assert session[:access_token].present?
  end

  test "should not login with invalid password" do
    post login_path, params: { login: @user.login, password: "WrongPassword123!" }
    assert_redirected_to login_path
    assert_equal "ログインIDまたはパスワードが正しくありません", flash[:alert]
    assert_nil session[:access_token]
  end

  test "should not login with invalid login" do
    post login_path, params: { login: "invalid_user", password: "Password123!" }
    assert_redirected_to login_path
    assert_equal "ログインIDまたはパスワードが正しくありません", flash[:alert]
    assert_nil session[:access_token]
  end

  test "should require login and password" do
    post login_path, params: { login: "", password: "" }
    assert_redirected_to login_path
    assert_includes flash[:alert], "ログインIDを入力してください"
    assert_includes flash[:alert], "パスワードを入力してください"
    assert_nil session[:access_token]
  end

  test "should handle account lock" do
    6.times do
      post login_path, params: { login: @user.login, password: "WrongPassword123!" }
    end

    post login_path, params: { login: @user.login, password: "Password123!" }
    assert_redirected_to login_path
    assert_equal "アカウントをロックしました", flash[:alert]
    assert_nil session[:access_token]
  end

  test "should logout" do
    # まずログイン
    post login_path, params: { login: @user.login, password: "Password123!" }
    assert session[:access_token].present?

    # ログアウト
    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:access_token]
  end

  test "should reset failed attempts after successful login" do
    # 失敗を3回記録
    3.times do
      post login_path, params: { login: @user.login, password: "WrongPassword123!" }
    end
    
    assert_equal 3, @user.reload.lock_count

    # 正しいパスワードでログイン
    post login_path, params: { login: @user.login, password: "Password123!" }
    assert_equal 0, @user.reload.lock_count
  end
end
