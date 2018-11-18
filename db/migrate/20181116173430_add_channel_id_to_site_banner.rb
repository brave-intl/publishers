class AddChannelIdToSiteBanner < ActiveRecord::Migration[5.2]
  def change
    add_column :site_banners, :channel_id, :uuid
  end
end
