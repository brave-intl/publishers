ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "selenium/webdriver"
require "minitest/rails/capybara"
require "webmock/minitest"
require "chromedriver/helper"
require 'sidekiq/testing'

Sidekiq::Testing.fake!

WebMock.allow_net_connect!

Chromedriver.set_version "2.35"

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu window-size=1680,1050) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

class Capybara::Rails::TestCase
  def setup
    Capybara.current_driver = :chrome
  end
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    self.use_transactional_tests = false

    setup do
      WebMock.disable_net_connect!
      DatabaseCleaner.start
    end

    teardown do
      DatabaseCleaner.clean
      WebMock.allow_net_connect!
    end

    def visit_authentication_url(publisher)
      get publisher_url(publisher, token: publisher.authentication_token)
    end
  end
end

# One time test suite setup.
DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with(:truncation)

require 'mocha/mini_test'
