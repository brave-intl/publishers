class AddPromoEnabled2018q1ToPublisher < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :promo_enabled_2018q1, :bool, default: false
  end
end
