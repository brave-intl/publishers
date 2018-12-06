class AddDefaultSiteBannerToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :default_site_banner, :uuid
  end
end
