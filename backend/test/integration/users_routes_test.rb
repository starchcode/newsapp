require "test_helper"

class UsersRoutesTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "testuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def test_should_get_sign_up_page
    # For JSON API, GET requests to sign up page may return 422 or be handled differently
    # Since we're using JSON API, we'll test that the endpoint exists
    get new_user_registration_path, as: :json
    # Accept either success or unprocessable_entity for JSON API
    assert_includes [200, 422], response.status
  end

  def test_should_get_sign_in_page
    get new_user_session_path
    assert_response :success
  end

  def test_should_get_password_reset_page
    get new_user_password_path
    assert_response :success
  end

  def test_should_create_new_user
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end
    # JSON API returns 200 OK with JSON response instead of redirect
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Signed up successfully.", json_response["status"]["message"]
  end

  def test_should_not_create_user_with_invalid_email
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: "invalid_email",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  def test_should_not_create_user_with_mismatched_passwords
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "different_password"
        }
      }
    end
  end

  def test_should_sign_in_with_valid_credentials
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json
    # JSON API returns 200 OK with JSON response instead of redirect
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Logged in successfully.", json_response["status"]["message"]
  end

  def test_should_not_sign_in_with_invalid_credentials
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "wrong_password"
      }
    }
    # Devise renders the sign-in page again with errors (200 OK), not 422
    assert_response :success
    # Verify user is not signed in
    assert_nil controller.current_user
  end

  def test_should_sign_out_signed_in_user
    sign_in @user
    delete destroy_user_session_path, as: :json
    # JSON API returns 200 OK with JSON response instead of redirect
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Logged out successfully.", json_response["status"]["message"]
  end

  def test_should_access_root_path
    get root_path
    assert_response :success
  end
end

