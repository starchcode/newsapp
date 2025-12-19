require "test_helper"

class KeywordsApiTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "testuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @other_user = User.create!(
      email: "otheruser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @keyword = Keyword.create!(user: @user, keyword: "existing keyword")
    @other_keyword = Keyword.create!(user: @other_user, keyword: "other user keyword")
  end

  def test_should_get_index_when_authenticated
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    get "/keywords", as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert_equal 1, json_response.length
    assert_equal @keyword.id, json_response.first["id"]
    assert_equal "existing keyword", json_response.first["keyword"]
  end

  def test_should_not_get_index_when_not_authenticated
    get "/keywords", as: :json

    assert_response :unauthorized
  end

  def test_should_only_see_own_keywords
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    get "/keywords", as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    keyword_ids = json_response.map { |k| k["id"] }
    assert_includes keyword_ids, @keyword.id
    assert_not_includes keyword_ids, @other_keyword.id
  end

  def test_should_create_keyword_when_authenticated
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_difference "Keyword.count", 1 do
      post "/keywords", params: {
        keyword: {
          keyword: "new keyword"
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "new keyword", json_response["keyword"]
    assert_equal @user.id, json_response["user_id"]
  end

  def test_should_not_create_keyword_when_not_authenticated
    assert_no_difference "Keyword.count" do
      post "/keywords", params: {
        keyword: {
          keyword: "new keyword"
        }
      }, as: :json
    end

    assert_response :unauthorized
  end

  def test_should_not_create_duplicate_keyword_for_same_user
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_no_difference "Keyword.count" do
      post "/keywords", params: {
        keyword: {
          keyword: "existing keyword"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end

  def test_should_create_keyword_with_same_name_for_different_user
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @other_user.email,
        password: "password123"
      }
    }, as: :json

    assert_difference "Keyword.count", 1 do
      post "/keywords", params: {
        keyword: {
          keyword: "existing keyword"
        }
      }, as: :json
    end

    assert_response :created
  end

  def test_should_not_create_keyword_with_empty_string
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_no_difference "Keyword.count" do
      post "/keywords", params: {
        keyword: {
          keyword: ""
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  def test_should_not_create_keyword_with_too_long_string
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_no_difference "Keyword.count" do
      post "/keywords", params: {
        keyword: {
          keyword: "a" * 101
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  def test_should_destroy_own_keyword
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_difference "Keyword.count", -1 do
      delete "/keywords/#{@keyword.id}", as: :json
    end

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Keyword deleted successfully.", json_response["status"]["message"]
  end

  def test_should_not_destroy_keyword_when_not_authenticated
    assert_no_difference "Keyword.count" do
      delete "/keywords/#{@keyword.id}", as: :json
    end

    assert_response :unauthorized
  end

  def test_should_not_destroy_other_users_keyword
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_no_difference "Keyword.count" do
      delete "/keywords/#{@other_keyword.id}", as: :json
    end

    assert_response :forbidden
  end

  def test_should_return_keywords_ordered_by_created_at_desc
    Keyword.create!(user: @user, keyword: "newer keyword")
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    get "/keywords", as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response.length
    # Most recent should be first
    assert_equal "newer keyword", json_response.first["keyword"]
  end
end

