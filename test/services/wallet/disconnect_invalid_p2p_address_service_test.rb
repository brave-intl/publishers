# typed: false

require "test_helper"

class Wallet::DisconnectInvalidP2pAddressServiceTest < ActiveSupport::TestCase
  # The fixtures pair prohibited_list(:three) with crypto_addresses(:prohibited_sol_address),
  # so exactly one address is prohibited before any setup.
  test "destroys the crypto addresses that match the Prohibited list" do
    prohibited = crypto_addresses(:prohibited_sol_address)

    assert_difference -> { CryptoAddress.count }, -1 do
      Wallet::DisconnectInvalidP2pAddressService.build.call
    end

    assert_not CryptoAddress.exists?(prohibited.id)
  end

  test "leaves addresses that aren't on the Prohibited list alone" do
    untouched = crypto_addresses(:eth_address)

    Wallet::DisconnectInvalidP2pAddressService.build.call

    assert CryptoAddress.exists?(untouched.id)
  end

  test "records a successful run" do
    assert_difference -> { ServiceRun.for_service(Wallet::DisconnectInvalidP2pAddressService).count }, 1 do
      Wallet::DisconnectInvalidP2pAddressService.build.call
    end
  end

  test "records a run and destroys nothing when no addresses are prohibited" do
    ProhibitedList.delete_all

    assert_no_difference -> { CryptoAddress.count } do
      Wallet::DisconnectInvalidP2pAddressService.build.call
    end

    assert_not_nil ServiceRun.last_success_at(Wallet::DisconnectInvalidP2pAddressService)
  end
end
