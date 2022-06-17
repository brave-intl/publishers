# typed: false
ENV["RAILS_ENV"] ||= "test"
require "simplecov"
SimpleCov.start "rails"

def not_arm?
  arch = `uname -m`.strip
  !(arch.include?("arm") || arch.include?("aarch64"))
end

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "webpacker"
require "selenium/webdriver"
require "webmock/minitest"
require "chromedriver/helper"
require "sidekiq/testing"
require "test_helpers/eyeshade_helper"
require "test_helpers/service_class_helpers"
require "test_helpers/mock_uphold_responses"
require "test_helpers/mock_gemini_responses"
require "test_helpers/mock_oauth2_responses"
require "test_helpers/mock_bitflyer_responses"
require "capybara/rails"
require "capybara/minitest"
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

Webpacker.compile

Sidekiq::Testing.fake!

WebMock.allow_net_connect!

# TODO, we can replace the below config with the following
# Capybara.enable_aria_label = true
# Capybara.default_driver = :selenium_chrome_headless

# NOTE:
# This is a workaround to allow basic test running on an M1
# This version of the chromedriver does not exist
# for the aarch64 architecture and the latest version (99)
# does not work.
#
# Attempting run tests at all on an M1 in docker context with this line active
# causes the entire test run to rail with an exception
#
# It does however mean that selenium tests do not work locally in the M1/Docker context
if not_arm?
  Chromedriver.set_version "2.38"
end

Capybara.register_driver "chrome" do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {
      binary: ENV["CHROME_BINARY"],
      args: %w[headless no-sandbox disable-gpu window-size=1680,1050]
    }.compact,
    loggingPrefs: {browser: "ALL"}
  )
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

# Have to use FF due to Chrome bug in linux
# See https://bugs.chromium.org/p/chromium/issues/detail?id=1010288
Capybara.register_driver "firefoxja" do |app|
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

Capybara.default_driver = "chrome"

VCR.configure do |config|
  config.cassette_library_dir = "./test/cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data("<ENCODED API KEY>") { Rails.application.secrets[:sendgrid_api_key] }
  config.before_record do |i|
    i.response.body.force_encoding("UTF-8")
    i.response.headers.delete("Set-Cookie")
    i.request.headers.delete("Authorization")
  end
  config.ignore_hosts "127.0.0.1", "localhost"
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = {match_requests_on: [:method, :uri, :body], decode_compressed_response: true}
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
        Kernel.silence_warnings { SsrfFilter.const_set(:DEFAULT_RESOLVER, lambda { |arg| default_resolver[arg] + [::IPAddr.new("42.42.42.42")] }) }
        @once = true
      end
    end

    # Add more helper methods to be used by all tests here...
  end
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

    self.use_transactional_tests = true

    setup do
      WebMock.disable_net_connect!
      stub_get_user
      mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
    end

    teardown do
      WebMock.allow_net_connect!
    end

    def visit_authentication_url(publisher)
      PublisherTokenGenerator.new(publisher: publisher).perform
      get publisher_url(publisher, token: publisher.authentication_token)
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

      def url(a, b)
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
