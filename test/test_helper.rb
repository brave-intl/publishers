# typed: false

ENV["RAILS_ENV"] ||= "test"
require "simplecov"
SimpleCov.start "rails"
require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "shakapacker"
require "selenium-webdriver"
require "webmock/minitest"
require "sidekiq/testing"
require "test_helpers/eyeshade_helper"
require "test_helpers/service_class_helpers"
require "test_helpers/mock_uphold_responses"
require "test_helpers/mock_gemini_responses"
require "test_helpers/mock_oauth2_responses"
require "test_helpers/mock_bitflyer_responses"
require "test_helpers/mock_rewards_responses"
require "test_helpers/sign_in_helpers"
require "minitest/rails"
require "minitest/retry"

if ENV["USE_MINITEST_RETRY"]
  Minitest::Retry.use!(
    retry_count: 3, # The number of times to retry. The default is 3.
    verbose: true, # Whether or not to display the message at the time of retry. The default is true.
    io: $stdout, # Display destination of retry when the message. The default is stdout.
    exceptions_to_retry: [], # List of exceptions that will trigger a retry (when empty, all exceptions will).
    methods_to_retry: [] # List of methods that will trigger a retry (when empty, all methods will).
  )
end
Shakapacker.compile
Sidekiq::Testing.fake!
WebMock.allow_net_connect!


VCR.configure do |config|
  config.cassette_library_dir = "./test/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.filter_sensitive_data("<ENCODED API KEY>") { Rails.configuration.pub_secrets[:sendgrid_api_key] }
  config.before_record do |i|
    i.response.body.force_encoding("UTF-8")
    i.response.headers.delete("Set-Cookie")
    i.request.headers.delete("Authorization")
  end
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = {match_requests_on: %i[method uri body], decode_compressed_response: true}
end

module ActiveSupport
  class TestCase
    include ServiceClassHelpers
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
    self.use_transactional_tests = true
    @once = false
    setup do
      Rails.cache.clear
      unless @once
        default_resolver = SsrfFilter::DEFAULT_RESOLVER
        Kernel.silence_warnings do
          SsrfFilter.const_set(:DEFAULT_RESOLVER, lambda { |arg|
            default_resolver[arg] + [::IPAddr.new("42.42.42.42")]
          })
        end
        @once = true
      end
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include ServiceClassHelpers
    include MockUpholdResponses
    include MockBitflyerResponses
    include MockGeminiResponses
    include MockOauth2Responses
    include SignInHelpers
    include Devise::Test::IntegrationHelpers
    self.use_transactional_tests = true
    # We should not stub methods here,
    # I did that only for the sake of moving things along previously.
    # I'm migrating previous tests that needed those stubs to the legacy class
    setup do
      WebMock.disable_net_connect!
    end
    teardown do
      WebMock.allow_net_connect!
    end

    def visit_authentication_url(publisher)
      PublisherTokenGenerator.new(publisher: publisher).perform
      get publisher_url(publisher, token: publisher.authentication_token)
    end
  end

  class LegacyIntegrationTest < IntegrationTest
    include ServiceClassHelpers
    include MockUpholdResponses
    include MockBitflyerResponses
    include MockGeminiResponses
    include MockOauth2Responses
    include SignInHelpers
    self.use_transactional_tests = true
    setup do
      stub_get_user
      mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
      WebMock.disable_net_connect!
    end
  end
end

module Publishers
  module Service
    class PublicS3Service
      def upload(a, b, c)
      end

      def url_expires_in
      end

      def url(_a, _b)
        "mock"
      end
    end
  end
end
# Load rake tasks here so it only happens one time. If tasks are loaded again they will run once for each time loaded.
require "rake"
Publishers::Application.load_tasks
# One time test suite setup.
DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with(:truncation)

class Minitest::Spec
  before :each do
    DatabaseCleaner.start
  end
  after :each do
    DatabaseCleaner.clean
  end
end

class NoTransactDBBleanupTest < ActiveSupport::TestCase
  def setup
    super
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  def teardown
    super
    DatabaseCleaner.clean
    DatabaseCleaner.strategy = :transaction
  end
end

require "mocha/minitest"
