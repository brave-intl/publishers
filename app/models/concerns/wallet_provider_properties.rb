# typed: true

module WalletProviderProperties
  extend T::Sig
  extend T::Helpers
  abstract!

  extend ActiveSupport::Concern

  included do
    after_destroy :clear_selected_wallet_provider
  end

  def clear_selected_wallet_provider
    return unless publisher.selected_wallet_provider == self
    publisher.update(selected_wallet_provider: nil)
  end

  # Ensuring this method is part of consistent wallet connection interface
  sig { abstract.returns(T.untyped) }
  def sync_connection!
  end
end
