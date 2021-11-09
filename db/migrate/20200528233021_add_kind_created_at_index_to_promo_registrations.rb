# typed: ignore
class AddKindCreatedAtIndexToPromoRegistrations < ActiveRecord::Migration[6.0]
  def change
    add_index :promo_registrations, [:kind, :created_at]
    remove_index :promo_registrations, :created_at
  end
end
