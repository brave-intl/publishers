class AddDefaultSiteBannerIdToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :default_site_banner_id, :uuid
  end
end
