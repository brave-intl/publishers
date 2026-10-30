# typed: false

require "test_helper"

class ServiceRunTest < ActiveSupport::TestCase
  test "record_success! stores the name of the service class" do
    run = ServiceRun.record_success!(ParseProhibitedListService)

    assert_predicate run, :persisted?
    assert_equal "ParseProhibitedListService", run.service_name
  end

  test "record_success! accepts a service name string" do
    run = ServiceRun.record_success!("Wallet::DisconnectInvalidP2pAddressService")

    assert_equal "Wallet::DisconnectInvalidP2pAddressService", run.service_name
  end

  test "service_name is required" do
    assert_raises(NoMethodError) do
      ServiceRun.record_success!(nil)
    end
  end

  test "last_success_at is nil when the service has never run" do
    assert_nil ServiceRun.last_success_at(ParseProhibitedListService)
  end

  test "last_success_at returns the most recent run, ignoring other services" do
    travel_to 2.days.ago do
      ServiceRun.record_success!(ParseProhibitedListService)
    end

    latest = nil
    travel_to 1.hour.ago do
      latest = ServiceRun.record_success!(ParseProhibitedListService)
    end

    # A more recent run of a different service must not be picked up.
    ServiceRun.record_success!(Wallet::DisconnectInvalidP2pAddressService)

    assert_equal latest.created_at.to_i, ServiceRun.last_success_at(ParseProhibitedListService).to_i
  end

  test "for_service only returns runs of that service" do
    ServiceRun.record_success!(ParseProhibitedListService)
    ServiceRun.record_success!(ParseProhibitedListService)
    ServiceRun.record_success!(Wallet::DisconnectInvalidP2pAddressService)

    assert_equal 2, ServiceRun.for_service(ParseProhibitedListService).count
    assert_equal 1, ServiceRun.for_service(Wallet::DisconnectInvalidP2pAddressService).count
  end

  test "most_recent_first orders newest run first" do
    travel_to 2.days.ago do
      ServiceRun.record_success!(ParseProhibitedListService)
    end
    newest = ServiceRun.record_success!(ParseProhibitedListService)

    assert_equal newest.id, ServiceRun.for_service(ParseProhibitedListService).most_recent_first.first.id
  end
end
