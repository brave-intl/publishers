# typed: ignore
class AddPublisherAdsEnabledAtToPublishers < ActiveRecord::Migration[6.0]
  def up
    add_column :site_channel_details, :ads_enabled_at, :datetime, default: nil
  end

  def down
    remove_column :site_channel_details, :ads_enabled_at
  end
end
