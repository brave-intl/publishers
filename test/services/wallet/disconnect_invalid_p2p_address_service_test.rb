# typed: false

require "test_helper"

class Wallet::DisconnectInvalidP2pAddressServiceTest < ActiveSupport::TestCase
  # The fixtures pair ofac_addresses(:three) with crypto_addresses(:banned_sol_address),
  # so exactly one address is banned before any setup.
  test "destroys the crypto addresses that match the OFAC list" do
    banned = crypto_addresses(:banned_sol_address)

    assert_difference -> { CryptoAddress.count }, -1 do
      Wallet::DisconnectInvalidP2pAddressService.build.call
    end

    assert_not CryptoAddress.exists?(banned.id)
  end

  test "leaves addresses that aren't on the OFAC list alone" do
    untouched = crypto_addresses(:eth_address)

    Wallet::DisconnectInvalidP2pAddressService.build.call

    assert CryptoAddress.exists?(untouched.id)
  end

  test "records a successful run" do
    assert_difference -> { ServiceRun.for_service(Wallet::DisconnectInvalidP2pAddressService).count }, 1 do
      Wallet::DisconnectInvalidP2pAddressService.build.call
    end
  end

  test "records a run and destroys nothing when no addresses are banned" do
    OfacAddress.delete_all

    assert_no_difference -> { CryptoAddress.count } do
      Wallet::DisconnectInvalidP2pAddressService.build.call
    end

    assert_not_nil ServiceRun.last_success_at(Wallet::DisconnectInvalidP2pAddressService)
  end
end
