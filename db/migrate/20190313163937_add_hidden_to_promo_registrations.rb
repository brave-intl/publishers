class AddHiddenToPromoRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_registrations, :hidden, :boolean, default: false, null: false
  end
end
