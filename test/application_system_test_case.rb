require "test_helper"
require "capybara/rails"
require "capybara/minitest"

# To not interfere with the usual port 3000 dev and to set a fixed port for the NEXTJS server to hit
Capybara.server_port = 4000

Capybara.register_driver :chromium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--window-size=1680,1050')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-gpu')
  options.add_argument('--headless')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :chromium_ja do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--window-size=1680,1050')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-gpu')
  options.add_argument('--headless')
  options.add_argument('--accept-lang=ja-JP')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :rack_test_jp do |app|
  Capybara::RackTest::Driver.new(app, headers: {"HTTP_ACCEPT_LANGUAGE" => "ja-JP"})
end
Capybara.default_driver = :chromium

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ServiceClassHelpers
  include MockUpholdResponses
  include MockOauth2Responses
  include SignInHelpers

  self.use_transactional_tests = false

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  # setup do
  #   stub_get_user
  # end
  #
  # teardown do
  #   Capybara.reset_sessions!
  #   Capybara.use_default_driver
  # end
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
