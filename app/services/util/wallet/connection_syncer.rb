# The hope is to make this the start of ripping out the
# oauth connection functions out of the model and into
# service classes
class Util::Wallet::ConnectionSyncer

  def self.build
    new
  end

  def call(publisher:)
    selected_wallet = publisher.selected_wallet_provider

    # Could make this dynamic, but the intention is to add typing and make this a union type
    # for exhaustiveness checking. Spelling it out to reduce magic in the codebase.
    syncer = case selected_wallet
    in UpholdConnection
      Uphold::WalletConnectionSyncer
    in GeminiConnection
      Gemini::WalletConnectionSyncer
    in BitflyerConnection
      Bitflyer::WalletConnectionSyncer
    else
      # Until we have sorbet typing with exhaustive checks, log any data problems in new relic
      LogException.perform(StandardError.new("Unknown Wallet Provider type: #{selected_wallet}"))
      nil
    end

    syncer.build.call(connection: selected_wallet) if syncer
  end
end
