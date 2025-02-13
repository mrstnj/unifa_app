require "test_helper"

class UserImageTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @valid_image = fixture_file_upload('test/fixtures/files/valid_image.jpg', 'image/jpeg')
    @large_image = fixture_file_upload('test/fixtures/files/large_image.png', 'image/png')
    @invalid_type_image = fixture_file_upload('test/fixtures/files/invalid.txt', 'text/plain')
  end

  test "should be valid with valid attributes" do
    user_image = UserImage.new(title: "Test Image", user: @user)
    user_image.image.attach(@valid_image)
    assert user_image.valid?
  end

  test "should require title" do
    user_image = UserImage.new(user: @user)
    user_image.image.attach(@valid_image)
    assert_not user_image.valid?
    assert_includes user_image.errors[:title], "タイトルを入力してください"
  end

  test "should not allow title longer than 30 characters" do
    user_image = UserImage.new(title: "a" * 31, user: @user)
    user_image.image.attach(@valid_image)
    assert_not user_image.valid?
    assert_includes user_image.errors[:title], "タイトルは30文字以内で入力してください"
  end

  test "should require image" do
    user_image = UserImage.new(title: "Test Image", user: @user)
    assert_not user_image.valid?
    assert_includes user_image.errors[:image], "画像ファイルを入力してください"
  end

  test "should not allow image larger than 5MB" do
    user_image = UserImage.new(title: "Test Image", user: @user)
    user_image.image.attach(@large_image)
    assert_not user_image.valid?
    assert_includes user_image.errors[:image], "画像ファイルのサイズは5MB以下にしてください"
  end

  test "should not allow non-image file types" do
    user_image = UserImage.new(title: "Test Image", user: @user)
    user_image.image.attach(@invalid_type_image)
    assert_not user_image.valid?
    assert_includes user_image.errors[:image], "画像ファイルはJPG、JPEG、PNG形式のみ対応しています"
  end

  test "should belong to user" do
    user_image = UserImage.new(title: "Test Image")
    assert_not user_image.valid?
    assert_includes user_image.errors[:user], "must exist"
  end
end
