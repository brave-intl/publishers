# typed: false

require "test_helper"

class PublishersHelperTest < ActionView::TestCase
  class FakePublisher
    attr_reader :uphold_connection

    def initialize(rates: {}, accounts: [], transactions: [], uphold_connection: nil)
      @uphold_connection = UpholdConnection.new(uphold_connection)
    end

    def partner?
      false
    end

    def only_user_funds?
      false
    end

    def no_grants?
      false
    end

    def selected_wallet_provider
      @uphold_connection
    end
  end

  test "can extract the uuid from an owner_identifier" do
    assert_equal "b8317d8a-78a4-48a6-9eeb-a2674c6455c4", publisher_id_from_owner_identifier("publishers#uuid:b8317d8a-78a4-48a6-9eeb-a2674c6455c4")
  end

  test "uphold_status_class returns a css class that corresponds to a publisher's uphold_status" do
    publisher = OpenStruct.new
    publisher.uphold_connection = OpenStruct.new

    publisher.uphold_connection.uphold_status = :verified
    assert_equal "uphold-complete", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = :access_parameters_acquired
    assert_equal "uphold-processing", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = :code_acquired
    assert_equal "uphold-processing", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = :reauthorization_needed
    assert_equal "uphold-reauthorization-needed", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = :unconnected
    assert_equal "uphold-unconnected", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = UpholdConnection::UpholdAccountState::RESTRICTED
    assert_equal "uphold-" + UpholdConnection::UpholdAccountState::RESTRICTED.to_s, uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = UpholdConnection::UpholdAccountState::BLOCKED
    assert_equal "uphold-complete", uphold_status_class(publisher)
  end
end
