class AddWalletProviderToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_reference :publishers, :wallet_provider, polymorphic: true, type: :uuid
  end
end
