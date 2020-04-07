require "test_helper"

class UpholdConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "login doesn't allow bad params" do
    get uphold_connections_login_path
    assert_equal 400, response.status
  end
end
