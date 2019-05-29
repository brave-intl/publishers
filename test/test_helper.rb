ENV["RAILS_ENV"] ||= "test"
require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "webpacker"
require "selenium/webdriver"
require "minitest/rails/capybara"
require "webmock/minitest"
require "chromedriver/helper"
require "sidekiq/testing"
require "test_helpers/eyeshade_helper"


# https://github.com/rails/rails/issues/31324
if ActionPack::VERSION::STRING >= "5.2.0"
  Minitest::Rails::TestUnit = Rails::TestUnit
end

Webpacker.compile

Sidekiq::Testing.fake!

WebMock.allow_net_connect!

# TODO, we can replace the below config with the following
# Capybara.enable_aria_label = true
# Capybara.default_driver = :selenium_chrome_headless

Chromedriver.set_version "2.38"

Capybara.register_driver "chrome" do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
          binary: ENV["CHROME_BINARY"],
          args: %w{headless no-sandbox disable-gpu window-size=1680,1050}
      }.compact,
      loggingPrefs: { browser: 'ALL' }
  )
  driver = Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      desired_capabilities: capabilities
  )
end

Capybara.default_driver = "chrome"

class Capybara::Rails::TestCase
  def setup
    Capybara.current_driver = "chrome"
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "./test/cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data("<ENCODED API KEY>") { Rails.application.secrets[:sendgrid_api_key] }
  config.ignore_hosts '127.0.0.1', 'localhost'
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = { match_requests_on: [:method, :uri, :body] }
end


module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
    self.use_transactional_tests = true

    # Add more helper methods to be used by all tests here...
  end
end

module Capybara
  module Rails
    class TestCase < ::ActiveSupport::TestCase
      self.use_transactional_tests = false

      setup do
        DatabaseCleaner.start
      end

      teardown do
        DatabaseCleaner.clean
      end

      def js_logs
        page.driver.browser.manage.logs.get(:browser)
      end

      def wait_until
        require "timeout"
        Timeout.timeout(Capybara.default_max_wait_time) do
          sleep(0.1) until value = yield
          value
        end
      end
    end
  end
end

module ActionDispatch
  class IntegrationTest
    self.use_transactional_tests = true

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
end

module Publishers
  module Service
    class PublicS3Service
      def upload(a, b, c) ; end
      def url_expires_in ; end
      def url(a, b)
        'mock'
      end
    end
  end
end

# Load rake tasks here so it only happens one time. If tasks are loaded again they will run once for each time loaded.
require 'rake'
Publishers::Application.load_tasks

# One time test suite setup.
DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with(:truncation)

require 'mocha/minitest'
