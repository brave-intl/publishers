require "test_helper"
require "shared/mailer_test_helper"

class Api::Public::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'a site not yet verified' do
    get "/api/public/channels/identity?publisher=brave.com"
    assert_equal 200, response.status
    assert_equal "brave.com", JSON.parse(response.body)["SLD"]
    assert_equal ""         , JSON.parse(response.body)["RLD"]
    assert_equal ""         , JSON.parse(response.body)["QLD"]
    assert_equal "brave.com", JSON.parse(response.body)["publisher"]
    assert_nil   JSON.parse(response.body)['properties']
  end

  test 'a site that is verified' do
    channel = channels(:verified)
    get "/api/public/channels/identity?publisher=#{channel.details.brave_publisher_id}"

    assert_equal channel.details.brave_publisher_id , JSON.parse(response.body)["SLD"]
    assert_equal ""                                 , JSON.parse(response.body)["RLD"]
    assert_equal ""                                 , JSON.parse(response.body)["QLD"]
    assert_equal true                               , JSON.parse(response.body)['properties']['verified']
  end
end
