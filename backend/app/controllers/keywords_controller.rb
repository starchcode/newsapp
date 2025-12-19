class KeywordsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  load_and_authorize_resource except: [:index, :create]

  respond_to :json

  def index
    @keywords = current_user.keywords.order(created_at: :desc)
    authorize! :read, Keyword
    render json: @keywords.as_json()
  end

  def create
    @keyword = current_user.keywords.build(keyword_params)
    authorize! :create, @keyword

    if @keyword.save
      render json: @keyword.as_json(), status: :created
    else
      render json: {
        status: { code: 422, message: "Keyword couldn't be created. #{@keyword.errors.full_messages.to_sentence}" },
        errors: @keyword.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @keyword
    if @keyword.destroy
      render json: {
        status: { code: 200, message: 'Keyword deleted successfully.' }
      }, status: :ok
    else
      render json: {
        status: { code: 422, message: "Keyword couldn't be deleted." },
        errors: @keyword.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def keyword_params
    params.require(:keyword).permit(:keyword)
  end
end

