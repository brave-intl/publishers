require "test_helper"

describe TwoFactorAuthenticationRemoval do
  let(:two_factor_authentication_removal) { TwoFactorAuthenticationRemoval.new }

  it "must be valid" do
    value(two_factor_authentication_removal).must_be :valid?
  end
end
