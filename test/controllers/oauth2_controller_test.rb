require "test_helper"

class Oauth2ControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  before do
    VCR.insert_cassette(name, record: :new_episodes)
  end

  after do
    VCR.eject_cassette
  end

  test "code redirects" do
    publisher = publishers(:completed)
    sign_in publisher
    Oauth2Controller.any_instance.stubs(:state_verified?).returns(true)
    get(publishers_uphold_verified_path(code: "123"))
    assert_response :redirect
  end

  test "uphold connection create" do
    publisher = publishers(:completed)
    sign_in publisher
    Oauth2Controller.any_instance.stubs(:state_verified?).returns(true)
    post(connection_uphold_connection_path(code: "123"))
    assert_response :redirect
  end
end
