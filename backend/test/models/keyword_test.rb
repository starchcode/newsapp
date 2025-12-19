require "test_helper"

class KeywordTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "testuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def test_should_be_valid_with_valid_attributes
    keyword = Keyword.new(user: @user, keyword: "test keyword")
    assert keyword.valid?
  end

  def test_should_require_user
    keyword = Keyword.new(keyword: "test keyword")
    assert_not keyword.valid?
    assert_includes keyword.errors[:user], "must exist"
  end

  def test_should_require_keyword
    keyword = Keyword.new(user: @user)
    assert_not keyword.valid?
    assert_includes keyword.errors[:keyword], "can't be blank"
  end

  def test_should_require_keyword_minimum_length
    keyword = Keyword.new(user: @user, keyword: "")
    assert_not keyword.valid?
  end

  def test_should_require_keyword_maximum_length
    keyword = Keyword.new(user: @user, keyword: "a" * 101)
    assert_not keyword.valid?
    assert_includes keyword.errors[:keyword], "is too long (maximum is 100 characters)"
  end

  def test_should_enforce_uniqueness_per_user
    Keyword.create!(user: @user, keyword: "unique keyword")
    duplicate = Keyword.new(user: @user, keyword: "unique keyword")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:keyword], "already exists for this user"
  end

  def test_should_allow_same_keyword_for_different_users
    user2 = User.create!(
      email: "user2@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    Keyword.create!(user: @user, keyword: "shared keyword")
    keyword2 = Keyword.new(user: user2, keyword: "shared keyword")
    assert keyword2.valid?
  end

  def test_should_belong_to_user
    keyword = Keyword.create!(user: @user, keyword: "test")
    assert_equal @user, keyword.user
  end

  def test_should_destroy_keyword_when_user_is_destroyed
    keyword = Keyword.create!(user: @user, keyword: "test")
    @user.destroy
    assert_not Keyword.exists?(keyword.id)
  end
end
