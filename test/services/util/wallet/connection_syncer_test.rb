# frozen_string_literal: true

require "test_helper"

class Util::Wallet::ConnectionSyncerTest < ActiveSupport::TestCase
  test "with no wallet does nothing" do
    LogException.expects("perform").at_least_once.returns(1)
    refute Util::Wallet::ConnectionSyncer.new.call(publisher: publishers(:notes))
  end

  test "Uphold" do
    UpholdConnection.any_instance.expects("sync_connection!").at_least_once.returns(1)
    Util::Wallet::ConnectionSyncer.new.call(publisher: publishers(:verified))
  end

  test "Gemini" do
    GeminiConnection.any_instance.expects("sync_connection!").at_least_once.returns(1)
    Util::Wallet::ConnectionSyncer.new.call(publisher: publishers(:top_referrer_gemini))
  end

  test "Bitflyer" do
    Bitflyer::WalletConnectionSyncer.any_instance.expects("call").at_least_once.returns(1)
    Util::Wallet::ConnectionSyncer.new.call(publisher: publishers(:top_referrer_bitflyer))
  end
end
