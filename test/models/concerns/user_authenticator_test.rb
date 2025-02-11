require "test_helper"

class UserAuthenticatorTest < ActiveSupport::TestCase
  class TestUser < ApplicationRecord
    self.table_name = "users"
    include UserAuthenticator
  end

  def setup
    @user = TestUser.new(
      login: "test_user",
      password: "Password123!"
    )
  end

  test "should authenticate with correct password" do
    @user.save!
    authenticated_user = TestUser.authenticate(@user.login, "Password123!")
    assert_equal @user, authenticated_user
  end

  test "should not authenticate with incorrect password" do
    @user.save!
    authenticated_user = TestUser.authenticate(@user.login, "WrongPassword123!")
    assert_nil authenticated_user
  end

  test "should not authenticate with incorrect login" do
    @user.save!
    authenticated_user = TestUser.authenticate("wrong_login", "Password123!")
    assert_nil authenticated_user
  end

end 