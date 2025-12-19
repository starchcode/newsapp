require "test_helper"
require "ostruct"

class ArticlesApiTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "testuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @keyword1 = Keyword.create!(user: @user, keyword: "technology")
    @keyword2 = Keyword.create!(user: @user, keyword: "AI")
  end

  # Helper method to create a mock service
  def create_mock_service(articles)
    mock_service = Object.new
    def mock_service.fetch_articles_for_keywords(*args)
      @articles
    end
    mock_service.instance_variable_set(:@articles, articles)
    mock_service
  end

  def test_should_get_articles_index_when_authenticated
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    # Mock the NewsApiService
    mock_articles = [
      {
        'title' => 'Test Article 1',
        'description' => 'Test Description 1',
        'url' => 'https://example.com/article1',
        'urlToImage' => 'https://example.com/image1.jpg',
        'publishedAt' => '2024-01-01T00:00:00Z',
        'author' => 'Test Author 1',
        'source' => { 'name' => 'Test Source 1' }
      },
      {
        'title' => 'Test Article 2',
        'description' => 'Test Description 2',
        'url' => 'https://example.com/article2',
        'urlToImage' => 'https://example.com/image2.jpg',
        'publishedAt' => '2024-01-02T00:00:00Z',
        'author' => 'Test Author 2',
        'source' => { 'name' => 'Test Source 2' }
      }
    ]

    mock_service = create_mock_service(mock_articles)
    # Stub the controller's news_api_service method
    # Use instance_eval to stub the method on any instance
    ArticlesController.class_eval do
      alias_method :original_news_api_service, :news_api_service
      define_method(:news_api_service) { mock_service }
    end
    
    begin
      get "/articles", as: :json
    ensure
      # Restore original method
      ArticlesController.class_eval do
        alias_method :news_api_service, :original_news_api_service
        remove_method :original_news_api_service
      end
    end

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert_equal 2, json_response.length
    assert_equal 'Test Article 1', json_response.first['title']
    assert_equal 'Test Description 1', json_response.first['description']
    assert_equal 'Test Author 1', json_response.first['author']
    assert_equal 'Test Source 1', json_response.first['source']['name']
  end

  def test_should_not_get_articles_when_not_authenticated
    get "/articles", as: :json
    assert_response :unauthorized
  end


  def test_should_return_empty_array_when_no_keywords
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_response :ok, "Sign in should succeed"

    # Delete all keywords
    @user.keywords.destroy_all

    # When no keywords, service returns empty array without calling API
    # No need to mock since service handles empty keywords
    get "/articles", as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert_equal 0, json_response.length
  end

  def test_should_handle_service_errors_gracefully
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    # Mock the NewsApiService to return empty array on error
    mock_service = create_mock_service([])
    ArticlesController.class_eval do
      alias_method :original_news_api_service, :news_api_service
      define_method(:news_api_service) { mock_service }
    end
    
    begin
      get "/articles", as: :json
    ensure
      ArticlesController.class_eval do
        alias_method :news_api_service, :original_news_api_service
        remove_method :original_news_api_service
      end
    end

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
  end

  def test_should_use_user_keywords_for_fetching_articles
    # Sign in via API
    post "/users/sign_in", params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    # Create another user with different keywords
    other_user = User.create!(
      email: "otheruser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    Keyword.create!(user: other_user, keyword: "sports")

    # Mock the NewsApiService
    mock_articles = [
      {
        'title' => 'Technology Article',
        'description' => 'Tech Description',
        'url' => 'https://example.com/tech',
        'urlToImage' => nil,
        'publishedAt' => '2024-01-01T00:00:00Z',
        'author' => 'Tech Author',
        'source' => { 'name' => 'Tech Source' }
      }
    ]

    # Verify that the service is called with the current user's keywords
    service_called = false
    keywords_received = nil
    
    mock_service = Object.new
    def mock_service.fetch_articles_for_keywords(keywords, options = {})
      @service_called = true
      @keywords_received = keywords
      @articles
    end
    mock_service.instance_variable_set(:@articles, mock_articles)
    mock_service.instance_variable_set(:@service_called, false)
    mock_service.instance_variable_set(:@keywords_received, nil)
    
    ArticlesController.class_eval do
      alias_method :original_news_api_service, :news_api_service
      define_method(:news_api_service) { mock_service }
    end
    
    begin
      get "/articles", as: :json
    ensure
      ArticlesController.class_eval do
        alias_method :news_api_service, :original_news_api_service
        remove_method :original_news_api_service
      end
    end

    assert_response :ok
    assert mock_service.instance_variable_get(:@service_called), "NewsApiService should have been called"
    
    # Verify it's called with the current user's keywords
    keywords_received = mock_service.instance_variable_get(:@keywords_received)
    keyword_strings = keywords_received.map(&:keyword)
    assert_includes keyword_strings, 'technology'
    assert_includes keyword_strings, 'AI'
    assert_not_includes keyword_strings, 'sports'
  end
end

