class RemoveDonationsFromSiteBanners < ActiveRecord::Migration[6.1]
  def up
    remove_column :site_banners, :default_donation
    remove_column :site_banners, :donation_amounts
  end

  def down
    add_column :site_banners, :default_donation, :integer
    add_column :site_banners, :donation_amounts, :integer, array: true
  end
end
