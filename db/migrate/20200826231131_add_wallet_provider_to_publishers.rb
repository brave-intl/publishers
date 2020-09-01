class AddWalletProviderToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_reference :publishers, :selected_wallet_provider, polymorphic: true, type: :uuid, index: { name: :publishers_wallet_provider_type }
  end
end
