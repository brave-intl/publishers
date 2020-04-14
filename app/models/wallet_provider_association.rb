class WalletProviderAssociation < ActiveRecord::Base
  validates_presence_of :wallet_provider_id, :publisher, :denied
end
