class AddPublisherIdToPromoCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_campaigns, :publisher_id, :uuid
  end
end
