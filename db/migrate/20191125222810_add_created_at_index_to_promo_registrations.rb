class AddCreatedAtIndexToPromoRegistrations < ActiveRecord::Migration[6.0]
  def change
    add_index :promo_registrations, :created_at
  end
end
