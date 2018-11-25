class AddDefaultToSiteBanner < ActiveRecord::Migration[5.2]
  def change
    add_column :site_banners, :default, :boolean, null: false, default: false
  end
end
