# typed: ignore
module WalletProviderProperties
  extend ActiveSupport::Concern

  included do
    after_destroy :clear_selected_wallet_provider
  end

  def clear_selected_wallet_provider
    return unless publisher.selected_wallet_provider == self
    publisher.update(selected_wallet_provider: nil)
  end
end
