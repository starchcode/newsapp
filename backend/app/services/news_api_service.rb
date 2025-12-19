require 'news-api'

class NewsApiService
  def initialize
    @api_key = ENV['NEWS_API_KEY']
    @news = News.new(@api_key) if @api_key
  end

  def fetch_articles_for_keywords(keywords, limit: 20)
    return [] if keywords.empty? || @api_key.blank?

    # Combine all keywords into a query string
    # NewsAPI supports OR queries, so we'll combine them
    query = keywords.map { |k| k.keyword }.join(' AND ')
    
    begin
      # Fetch articles using the everything endpoint
      # Sort by publishedAt to get recent articles
      response = @news.get_everything(
        q: query,
        sortBy: 'publishedAt',
        language: 'en',
        pageSize: limit
      )
      
      # The gem returns a hash with 'articles' key containing article objects
      # Convert article objects to hashes for JSON serialization
      articles = if response.is_a?(Hash)
        (response['articles'] || response[:articles] || []).map do |article|
          article_to_hash(article)
        end
      elsif response.is_a?(Array)
        response.map { |article| article_to_hash(article) }
      else
        []
      end
      
      articles.first(limit)
    rescue => e
      Rails.logger.error "NewsAPI Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      []
    end
  end

  private

  def article_to_hash(article)
    # Convert article object to hash
    if article.respond_to?(:to_h)
      article.to_h
    elsif article.is_a?(Hash)
      article
    else
      {
        title: article.respond_to?(:title) ? article.title : nil,
        description: article.respond_to?(:description) ? article.description : nil,
        url: article.respond_to?(:url) ? article.url : nil,
        urlToImage: article.respond_to?(:urlToImage) ? article.urlToImage : nil,
        publishedAt: article.respond_to?(:publishedAt) ? article.publishedAt : nil,
        author: article.respond_to?(:author) ? article.author : nil,
        source: article.respond_to?(:source) ? source_to_hash(article.source) : nil
      }
    end
  end

  def source_to_hash(source)
    if source.respond_to?(:to_h)
      source.to_h
    elsif source.is_a?(Hash)
      source
    else
      {
        name: source.respond_to?(:name) ? source.name : nil
      }
    end
  end
end

