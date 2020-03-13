class DropPromoIdFromPromoRegistrations < ActiveRecord::Migration[6.0]
  def up
    add_index :promo_registrations, :referral_code, unique: true
    remove_index :promo_registrations, name: "index_promo_registrations_on_promo_id_and_referral_code"
    remove_column :promo_registrations, :promo_id
  end
end
