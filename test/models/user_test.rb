require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      login: "test_user",
      password: "Password123!"
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require login" do
    @user.login = nil
    assert_not @user.valid?
    assert_includes @user.errors[:login], "can't be blank"
  end

  test "should require unique login" do
    @user.save!
    duplicate_user = User.new(
      login: @user.login,
      password: "Password123!"
    )
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:login], "has already been taken"
  end

  test "should validate password format" do
    user = User.new(login: "test_user")

    # パスワードなし
    user.password = nil
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"

    # 短すぎるパスワード
    user.password = "Pass1!"
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"

    # 大文字なし
    user.password = "password123!"
    assert_not user.valid?

    # 小文字なし
    user.password = "PASSWORD123!"
    assert_not user.valid?

    # 数字なし
    user.password = "Password!!!"
    assert_not user.valid?

    # 記号なし
    user.password = "Password123"
    assert_not user.valid?

    # 有効なパスワード
    user.password = "Password123!"
    assert user.valid?
  end

  test "should issue access token" do
    @user.save!
    @user.issue_access_token

    assert_not_nil @user.access_token
    assert_not_nil @user.access_token_expire_date
  end

  test "should handle lock check correctly" do
    @user.save!

    # ロックされていない状態
    assert_nothing_raised { @user.lock_check }

    # ロックカウントが6未満
    @user.update_column(:lock_count, 5)
    assert_nothing_raised { @user.lock_check }

    # ロックカウントが6以上
    @user.update_columns(lock_count: 6, unlock_time: 1.minute.from_now)
    assert_raises(Exceptions::LockedError) { @user.lock_check }

    # ロック解除時間が過ぎている場合
    @user.update_columns(lock_count: 6, unlock_time: 1.minute.ago)
    assert_nothing_raised { @user.lock_check }
    assert_equal 0, @user.reload.lock_count
  end

  test "should authenticate with lock check" do
    @user.save!

    # 正常な認証
    authenticated_user = User.authenticate_with_lock(@user.login, "Password123!")
    assert_equal @user, authenticated_user
    assert_equal 0, authenticated_user.lock_count

    # 失敗時のロックカウント増加
    authenticated_user = User.authenticate_with_lock(@user.login, "WrongPassword123!")
    assert_nil authenticated_user
    assert_equal 1, @user.reload.lock_count

    # ロック状態での認証
    @user.update_columns(lock_count: 6, unlock_time: 1.minute.from_now)
    assert_raises(Exceptions::LockedError) do
      User.authenticate_with_lock(@user.login, "Password123!")
    end
  end
end
