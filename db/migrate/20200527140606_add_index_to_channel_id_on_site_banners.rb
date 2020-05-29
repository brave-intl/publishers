class AddIndexToChannelIdOnSiteBanners < ActiveRecord::Migration[6.0]
  def change
    add_index :site_banners, :channel_id
  end
end
