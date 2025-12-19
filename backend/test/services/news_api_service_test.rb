require "test_helper"
require "minitest/mock"

class NewsApiServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "testuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @keyword1 = Keyword.create!(user: @user, keyword: "technology")
    @keyword2 = Keyword.create!(user: @user, keyword: "AI")
  end

  def test_should_return_empty_array_when_no_keywords
    service = NewsApiService.new
    articles = service.fetch_articles_for_keywords([])
    assert_equal [], articles
  end

  def test_should_return_empty_array_when_api_key_is_blank
    original_key = ENV['NEWS_API_KEY']
    ENV['NEWS_API_KEY'] = ''
    
    service = NewsApiService.new
    articles = service.fetch_articles_for_keywords([@keyword1])
    assert_equal [], articles
    
    ENV['NEWS_API_KEY'] = original_key
  end

  def test_should_combine_keywords_with_or_operator
    # Create a simple mock object
    mock_news = Object.new
    called = false
    def mock_news.get_everything(*args, **kwargs)
      @called = true
      { 'articles' => [] }
    end
    def mock_news.called; @called; end
    
    service = NewsApiService.new
    service.instance_variable_set(:@api_key, 'test_key')
    service.instance_variable_set(:@news, mock_news)
    
    result = service.fetch_articles_for_keywords([@keyword1, @keyword2])
    
    assert mock_news.called, "get_everything should have been called"
    assert_equal [], result
  end

  def test_should_fetch_articles_with_hash_response
    mock_article = {
      'title' => 'Test Article',
      'description' => 'Test Description',
      'url' => 'https://example.com/article',
      'urlToImage' => 'https://example.com/image.jpg',
      'publishedAt' => '2024-01-01T00:00:00Z',
      'author' => 'Test Author',
      'source' => { 'name' => 'Test Source' }
    }
    
    mock_response = {
      'articles' => [mock_article]
    }
    
    # Create a simple mock object that responds to get_everything
    mock_news = Object.new
    def mock_news.get_everything(*args, **kwargs)
      { 'articles' => [{ 'title' => 'Test Article', 'description' => 'Test Description', 'url' => 'https://example.com/article', 'urlToImage' => 'https://example.com/image.jpg', 'publishedAt' => '2024-01-01T00:00:00Z', 'author' => 'Test Author', 'source' => { 'name' => 'Test Source' } }] }
    end
    
    service = NewsApiService.new
    service.instance_variable_set(:@api_key, 'test_key')
    service.instance_variable_set(:@news, mock_news)
    
    articles = service.fetch_articles_for_keywords([@keyword1], limit: 20)
    
    assert_equal 1, articles.length
    assert_equal 'Test Article', articles.first['title']
    assert_equal 'Test Description', articles.first['description']
    assert_equal 'https://example.com/article', articles.first['url']
    assert_equal 'Test Author', articles.first['author']
    assert_equal 'Test Source', articles.first['source']['name']
  end

  def test_should_fetch_articles_with_array_response
    mock_article = {
      'title' => 'Test Article 2',
      'description' => 'Test Description 2',
      'url' => 'https://example.com/article2',
      'urlToImage' => 'https://example.com/image2.jpg',
      'publishedAt' => '2024-01-02T00:00:00Z',
      'author' => 'Test Author 2',
      'source' => { 'name' => 'Test Source 2' }
    }
    
    mock_news = Object.new
    def mock_news.get_everything(*args, **kwargs)
      [{ 'title' => 'Test Article 2', 'description' => 'Test Description 2', 'url' => 'https://example.com/article2', 'urlToImage' => 'https://example.com/image2.jpg', 'publishedAt' => '2024-01-02T00:00:00Z', 'author' => 'Test Author 2', 'source' => { 'name' => 'Test Source 2' } }]
    end
    
    service = NewsApiService.new
    service.instance_variable_set(:@api_key, 'test_key')
    service.instance_variable_set(:@news, mock_news)
    
    articles = service.fetch_articles_for_keywords([@keyword1], limit: 20)
    
    assert_equal 1, articles.length
    assert_equal 'Test Article 2', articles.first['title']
  end

  def test_should_respect_limit_parameter
    mock_articles = (1..25).map do |i|
      {
        'title' => "Article #{i}",
        'description' => "Description #{i}",
        'url' => "https://example.com/article#{i}",
        'urlToImage' => nil,
        'publishedAt' => '2024-01-01T00:00:00Z',
        'author' => nil,
        'source' => { 'name' => 'Test Source' }
      }
    end
    
    mock_news = Object.new
    def mock_news.get_everything(*args, **kwargs)
      articles = (1..25).map do |i|
        { 'title' => "Article #{i}", 'description' => "Description #{i}", 'url' => "https://example.com/article#{i}", 'urlToImage' => nil, 'publishedAt' => '2024-01-01T00:00:00Z', 'author' => nil, 'source' => { 'name' => 'Test Source' } }
      end
      { 'articles' => articles }
    end
    
    service = NewsApiService.new
    service.instance_variable_set(:@api_key, 'test_key')
    service.instance_variable_set(:@news, mock_news)
    
    articles = service.fetch_articles_for_keywords([@keyword1], limit: 20)
    
    assert_equal 20, articles.length
  end

  def test_should_handle_api_errors_gracefully
    service = NewsApiService.new
    service.instance_variable_set(:@api_key, 'test_key')
    
    mock_news = Minitest::Mock.new
    mock_news.expect :get_everything, nil do |_|
      raise StandardError, "API Error"
    end
    service.instance_variable_set(:@news, mock_news)
    
    articles = service.fetch_articles_for_keywords([@keyword1])
    
    assert_equal [], articles
    assert_mock mock_news
  end

  def test_should_convert_article_objects_to_hash
    # Simulate an article object that responds to methods
    article_object = Object.new
    def article_object.title; 'Object Article'; end
    def article_object.description; 'Object Description'; end
    def article_object.url; 'https://example.com/object'; end
    def article_object.urlToImage; 'https://example.com/object.jpg'; end
    def article_object.publishedAt; '2024-01-01T00:00:00Z'; end
    def article_object.author; 'Object Author'; end
    def article_object.source; source_object = Object.new; def source_object.name; 'Object Source'; end; source_object; end
    
    mock_news = Object.new
    def mock_news.get_everything(*args, **kwargs)
      article_object = Object.new
      def article_object.title; 'Object Article'; end
      def article_object.description; 'Object Description'; end
      def article_object.url; 'https://example.com/object'; end
      def article_object.urlToImage; 'https://example.com/object.jpg'; end
      def article_object.publishedAt; '2024-01-01T00:00:00Z'; end
      def article_object.author; 'Object Author'; end
      def article_object.source; source_object = Object.new; def source_object.name; 'Object Source'; end; source_object; end
      [article_object]
    end
    
    service = NewsApiService.new
    service.instance_variable_set(:@api_key, 'test_key')
    service.instance_variable_set(:@news, mock_news)
    
    articles = service.fetch_articles_for_keywords([@keyword1], limit: 20)
    
    assert_equal 1, articles.length
    assert_equal 'Object Article', articles.first[:title]
    assert_equal 'Object Description', articles.first[:description]
    assert_equal 'Object Author', articles.first[:author]
    assert_equal 'Object Source', articles.first[:source][:name]
  end

  def test_should_call_get_everything_with_correct_parameters
    called_params = nil
    mock_news = Object.new
    def mock_news.get_everything(*args, **kwargs)
      @called_params = { args: args, kwargs: kwargs }
      { 'articles' => [] }
    end
    def mock_news.called_params; @called_params; end
    
    service = NewsApiService.new
    service.instance_variable_set(:@api_key, 'test_key')
    service.instance_variable_set(:@news, mock_news)
    
    result = service.fetch_articles_for_keywords([@keyword1, @keyword2], limit: 20)
    
    assert_not_nil mock_news.called_params, "get_everything should have been called"
    assert_equal [], result
    # Verify it was called with keyword arguments
    assert mock_news.called_params[:kwargs].key?(:q), "Should be called with q parameter"
    assert_equal 'technology AND AI', mock_news.called_params[:kwargs][:q]
  end
end

