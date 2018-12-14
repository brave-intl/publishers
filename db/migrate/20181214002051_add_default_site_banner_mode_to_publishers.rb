class AddDefaultSiteBannerModeToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :default_site_banner_mode, :boolean, null: false, default: false
  end
end
