# typed: false

require "test_helper"
require "webmock/minitest"
require "test_helpers/csrf_getter"

class Api::Nextv1::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include CsrfGetter

  def setup
    ActionController::Base.allow_forgery_protection = true
  end

  def teardown
    ActionController::Base.allow_forgery_protection = false
  end

  before do
    @publisher = publishers(:default)
    sign_in @publisher
  end

  test "/api/nextv1/channels/destroy removes a channel from a publisher" do
    publisher = publishers(:default)
    details = SiteChannelDetails.new
    channel = Channel.create!(publisher: publisher, details: details)

    delete "/api/nextv1/channels/#{channel.id}", headers: {"HTTP_ACCEPT" => "application/json", "X-CSRF-Token" => get_csrf_token}

    assert_equal(204, response.status)
    assert_nil Channel.find_by(id: channel.id)
  end
end
