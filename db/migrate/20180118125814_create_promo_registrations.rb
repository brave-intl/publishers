class CreatePromoRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :promo_registrations, id: :uuid do |t|
      t.references :channel, type: :uuid, index: true, null: false
      t.string :promo_id, null: false
      t.string :referral_code, null: false
      
      t.timestamps
    end
  end
end