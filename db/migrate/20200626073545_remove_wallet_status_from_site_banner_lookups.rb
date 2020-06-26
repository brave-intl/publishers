class RemoveWalletStatusFromSiteBannerLookups < ActiveRecord::Migration[6.0]
  def change
    remove_column :site_banner_lookups, :wallet_status
  end
end
