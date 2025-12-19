ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)  # Temporarily disabled

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all  # Temporarily disabled - fixtures will be loaded when needed

    # Add more helper methods to be used by all tests here...
    begin
      include Devise::Test::IntegrationHelpers
    rescue NameError
      # Devise not installed yet - will be available after bundle install
    end
  end
end
