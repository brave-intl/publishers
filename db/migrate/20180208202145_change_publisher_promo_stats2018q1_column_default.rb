class ChangePublisherPromoStats2018q1ColumnDefault < ActiveRecord::Migration[5.0]
  def up
    change_column_default :publishers, :promo_stats_2018q1, {}
  end

  def down
    change_column_default :publishers, :promo_stats_2018q1, "{}"
  end
end
