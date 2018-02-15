class AddColumnsToPublisher < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :promo_stats_2018q1, :jsonb, null: false, default: '{}'
    add_column :publishers, :promo_stats_updated_at_2018q1, :datetime
  end
end
