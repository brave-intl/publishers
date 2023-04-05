require "test_helper"

describe CryptoAddressForChannel do
  it "only accepts approved chain types" do
    cafc = crypto_address_for_channels(:sol_address)
    cafc.chain = "DOGE"
    assert_raises do
      refute cafc.valid?
    end
  end

  it "will only accept one of each chain per channel" do
    cafc = crypto_address_for_channels(:sol_address)

    assert_raises do
      CryptoAddressForChannel.create!(address_id: cafc.address_id, channel_id: cafc.channel_id, chain: "SOL")
    end
  end
end
