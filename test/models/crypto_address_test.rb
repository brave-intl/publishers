require "test_helper"

describe CryptoAddress do
  it "only accepts approved chain types" do
    address = crypto_addresses(:sol_address)
    address.chain = "DOGE"
    refute address.valid?
  end

  it "will not allow address or chain to be changed after create" do
    address = crypto_addresses(:sol_address)
    assert address.valid?

    address.address = "totally random string"
    address.chain = "ETH"
    refute address.valid?

    assert_equal "can't be changed", address.errors.messages[:address][0]
    assert_equal "can't be changed", address.errors.messages[:chain][0]
  end
end
