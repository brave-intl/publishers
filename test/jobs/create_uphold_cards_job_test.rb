# typed: false
require "test_helper"
require "webmock/minitest"

class CreateUpholdCardsJobTest < ActiveJob::TestCase
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper
  include EyeshadeHelper
  include MockUpholdResponses

  before(:example) do
    stub_uphold_cards!
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  # Is it just me or were these tests identical?
  test "creates default currency card if wallet address missing" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:uphold_connected_details)
    publisher.default_currency = "BAT"
    publisher.uphold_connection.address = nil
    publisher.save!

    CreateUpholdCardsJob.perform_now(uphold_connection_id: publisher.uphold_connection.id)
    publisher.uphold_connection.reload
    assert_equal publisher.uphold_connection.address, "123e4567-e89b-12d3-a456-426655440000"
  end

  test "does not create default currency card if wallet address present" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_details)
    publisher.default_currency = "BAT"

    publisher.save!

    CreateUpholdCardsJob.perform_now(uphold_connection_id: publisher.uphold_connection.id)
    publisher.uphold_connection.reload
    assert_equal publisher.uphold_connection.address, "123e4567-e89b-12d3-a456-426655440000"
  end
end
