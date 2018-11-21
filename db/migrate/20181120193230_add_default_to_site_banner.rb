class AddDefaultToSiteBanner < ActiveRecord::Migration[5.2]
  def change
    change_column :site_banners, :default, :boolean, null: false, default: false
  end
end
