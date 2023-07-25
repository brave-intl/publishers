# typed: false

ENV["RAILS_ENV"] ||= "test"
require "simplecov"
SimpleCov.start "rails"
require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "shakapacker"
require "selenium-webdriver"
require "webmock/minitest"
require "webdrivers/geckodriver"
require "sidekiq/testing"
require "test_helpers/eyeshade_helper"
require "test_helpers/service_class_helpers"
require "test_helpers/mock_uphold_responses"
require "test_helpers/mock_gemini_responses"
require "test_helpers/mock_oauth2_responses"
require "test_helpers/mock_bitflyer_responses"
require "test_helpers/mock_rewards_responses"
require "capybara/rails"
require "capybara/minitest"
require "minitest/rails"
Shakapacker.compile
Sidekiq::Testing.fake!
WebMock.allow_net_connect!
Capybara.register_driver "firefox" do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  opts = Selenium::WebDriver::Firefox::Options.new(profile: profile)
  opts.args << "--headless"
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    options: opts
  )
end

Capybara.register_driver :firefox_ja do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["intl.accept_languages"] = "ja-JP"
  opts = Selenium::WebDriver::Firefox::Options.new(profile: profile)
  opts.args << "--headless"
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    options: opts
  )
end

Capybara.register_driver :rack_test_jp do |app|
  Capybara::RackTest::Driver.new(app, headers: {"HTTP_ACCEPT_LANGUAGE" => "ja-JP"})
end
Capybara.default_driver = "firefox"
driver_urls = Webdrivers::Common.subclasses.map do |driver|
  Addressable::URI.parse(driver.base_url).host
end
driver_urls << "127.0.0.1"
driver_urls << "localhost"
driver_urls << "objects.githubusercontent.com" # pulling firefox
VCR.configure do |config|
  config.cassette_library_dir = "./test/cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data("<ENCODED API KEY>") { Rails.configuration.pub_secrets[:sendgrid_api_key] }
  config.before_record do |i|
    i.response.body.force_encoding("UTF-8")
    i.response.headers.delete("Set-Cookie")
    i.request.headers.delete("Authorization")
  end
  config.ignore_hosts(*driver_urls)
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
    # Add more helper methods to be used by all tests here...
  end

  # I'm creating an independent class because
  # all of the other cases I've handled are just out of preserving
  # existing specs. I don't think it is actually a good idea
  # to blanketly stub requests in a test setup.
end

module Capybara
  module Rails
    class TestCase < ::ActiveSupport::TestCase
      include ServiceClassHelpers
      include MockUpholdResponses
      include MockOauth2Responses
      self.use_transactional_tests = false
      # Make the Capybara DSL available in all integration tests
      include Capybara::DSL
      # Make `assert_*` methods behave like Minitest assertions
      include Capybara::Minitest::Assertions
      setup do
        stub_get_user
      end
      teardown do
        Capybara.reset_sessions!
        Capybara.use_default_driver
      end

      def js_logs
        page.driver.browser.manage.logs.get(:browser)
      end

      def wait_until
        require "timeout"
        Timeout.timeout(Capybara.default_max_wait_time) do
          sleep(0.1) until (value = yield)
          value
        end
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
