require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def test_should_be_valid_with_valid_attributes
    assert @user.valid?
  end

  def test_should_require_email
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  def test_should_require_unique_email
    @user.save
    duplicate_user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  def test_should_require_valid_email_format
    @user.email = "invalid_email"
    assert_not @user.valid?
    assert_includes @user.errors[:email], "is invalid"
  end

  def test_should_require_password
    @user.password = nil
    assert_not @user.valid?
    assert_includes @user.errors[:password], "can't be blank"
  end

  def test_should_require_password_confirmation
    @user.password_confirmation = "different_password"
    assert_not @user.valid?
    assert_includes @user.errors[:password_confirmation], "doesn't match Password"
  end

  def test_should_require_password_minimum_length
    @user.password = "short"
    @user.password_confirmation = "short"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 6 characters)"
  end

  def test_should_save_user_with_valid_attributes
    assert_difference "User.count", 1 do
      @user.save
    end
  end

  def test_should_authenticate_with_correct_password
    @user.save
    authenticated_user = User.find_by(email: "test@example.com").valid_password?("password123")
    assert authenticated_user
  end

  def test_should_not_authenticate_with_incorrect_password
    @user.save
    authenticated_user = User.find_by(email: "test@example.com").valid_password?("wrong_password")
    assert_not authenticated_user
  end
end

