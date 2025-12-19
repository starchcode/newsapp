class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # Skip CSRF token verification for JSON API
  skip_before_action :verify_authenticity_token

  # Override create to handle JSON responses for both success and failure
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  rescue => e
    # Handle authentication failure with JSON response
    render json: {
      status: { code: 401, message: 'Invalid Email or password.' },
      error: 'Invalid Email or password.'
    }, status: :unauthorized
  end

  # Override destroy to check user before sign out
  def destroy
    @user_was_signed_in = user_signed_in?
    super
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: 'Logged in successfully.' },
      data: {
        email: resource.email
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    # Check if user was signed in before destroy was called
    if @user_was_signed_in
      render json: {
        status: { code: 200, message: 'Logged out successfully.' }
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: "Couldn't find an active session." }
      }, status: :unauthorized
    end
  end
end

