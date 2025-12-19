class ArticlesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  respond_to :json

  def index
    keywords = current_user.keywords
    service = news_api_service
    #TODO: add pagination
    articles = service.fetch_articles_for_keywords(keywords, limit: 20)
    
    render json: articles
  end

  private

  def news_api_service
    @news_api_service ||= NewsApiService.new
  end
end

