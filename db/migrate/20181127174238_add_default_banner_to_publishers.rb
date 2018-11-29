class AddDefaultBannerToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :default_banner, :uuid
  end
end
