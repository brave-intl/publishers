class AddPublisherAdsEnabledAtToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_column :publishers, :ads_enabled_at, :datetime, default: nil
  end
end
