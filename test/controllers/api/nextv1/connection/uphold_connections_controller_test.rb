# typed: false

require "test_helper"
require "webmock/minitest"
require "test_helpers/csrf_getter"

class Api::Nextv1::Connection::UpholdConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include CsrfGetter

  let(:path) { "/api/nextv1/connection/uphold_connection" }
  let(:publisher) { publishers(:verified) }

  def setup
    ActionController::Base.allow_forgery_protection = true
  end

  def teardown
    ActionController::Base.allow_forgery_protection = false
  end

  def json_headers
    {"HTTP_ACCEPT" => "application/json", "X-CSRF-Token" => (@csrf_token ||= get_csrf_token)}
  end

  def state_set_cookie_header
    Array(response.headers["set-cookie"]).flat_map { |h| h.split("\n") }.find { |c| c.start_with?("_state=") }
  end

  describe "#create" do
    before do
      sign_in(publisher)
    end

    it "is blocked while uphold is under maintenance" do
      post path, headers: json_headers

      assert_response :service_unavailable
    end

    it "does not issue a state cookie while under maintenance" do
      post path, headers: json_headers

      assert_nil state_set_cookie_header
    end
  end

  describe "#show" do
    before do
      sign_in(publisher)
    end

    it "returns the uphold connection status as json" do
      get path, headers: {"HTTP_ACCEPT" => "application/json"}

      assert_response :ok
      body = response.parsed_body
      connection = publisher.uphold_connection

      assert_equal connection.uphold_status.to_s, body["uphold_status"]
      assert_equal true, body["uphold_is_member"]
      assert_equal "BAT", body["default_currency"]
      assert body.key?("uphold_status_summary")
      assert body.key?("uphold_status_description")
      assert body.key?("uphold_username")
    end

    it "returns empty defaults for a publisher without a connection" do
      UpholdConnection.where(publisher: publisher).delete_all

      get path, headers: {"HTTP_ACCEPT" => "application/json"}

      assert_response :ok
      assert_equal "", response.parsed_body["uphold_status"]
      assert_equal false, response.parsed_body["uphold_is_member"]
      assert_nil response.parsed_body["default_currency"]
    end
  end

  describe "#destroy" do
    before do
      sign_in(publisher)
    end

    it "removes the connection and returns 200" do
      assert_difference("UpholdConnection.count", -1) do
        delete path, headers: json_headers
      end

      assert_response :ok
      assert_nil publisher.reload.uphold_connection
    end
  end

  describe "#destroy for a suspended publisher" do
    let(:publisher) { publishers(:suspended) }

    before do
      # Suspended publishers are halted before the CSRF cookie is set, so fetch it first.
      @csrf_token = get_csrf_token
      sign_in(publisher)
    end

    it "does not remove the connection" do
      assert_no_difference("UpholdConnection.count") do
        delete path, headers: json_headers
      end

      assert_response :found
      assert_equal Rails.application.routes.url_helpers.suspended_error_publishers_path, response.parsed_body["location"]
    end
  end
end
