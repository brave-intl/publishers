class RemovePromoStatsFromPublishers < ActiveRecord::Migration[5.2]
  def change
    remove_column :publishers, :promo_stats_2018q1
    remove_column :publishers, :promo_stats_updated_at_2018q1
  end
end
