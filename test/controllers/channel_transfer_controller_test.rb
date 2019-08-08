require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class ChannelTransferControllerTest < ActionDispatch::IntegrationTest
  include ChannelsHelper
  include ActionMailer::TestHelper

  test "#reject_transfer goes through and redirects to home with valid contest token" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)

    # contest channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    assert_enqueued_jobs(4) do
      get token_reject_transfer_path(channel, channel.contest_token)
    end

    assert_redirected_to home_publishers_path
    assert_equal I18n.t("shared.channel_transfer_rejected"), flash[:notice] 
  end

  test "#rejects_transfer does not go thorugh and redirects to home with fake contest token" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)
    
    # contest channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform
    get token_reject_transfer_path(channel, "fake token")

    assert response.status, 404
    assert_redirected_to home_publishers_path
    assert_equal I18n.t("shared.channel_not_found"), flash[:notice] 
  end
end
