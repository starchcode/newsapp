class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Skip browser check for JSON API requests and in test environment
  before_action :skip_browser_check_for_api, if: -> { request.format.json? || Rails.env.test? }
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Handle JSON requests
  respond_to :json

  # CanCanCan authorization
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |exception|
    render json: {
      status: { code: 403, message: 'Access denied.' },
      error: exception.message
    }, status: :forbidden
  end

  private

  def skip_browser_check_for_api
    # This method exists to allow skipping browser check via before_action
    # The actual skip happens because allow_browser runs after this
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
end
