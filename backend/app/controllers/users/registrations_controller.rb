class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  
  # Skip CSRF token verification for JSON API
  skip_before_action :verify_authenticity_token

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: {
          email: resource.email
        }
      }, status: :ok
    else
      render json: {
        status: { code: 422, message: "User couldn't be created. #{resource.errors.full_messages.to_sentence}" },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end

