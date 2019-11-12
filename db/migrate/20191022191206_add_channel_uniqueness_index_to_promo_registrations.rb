class AddChannelUniquenessIndexToPromoRegistrations < ActiveRecord::Migration[6.0]
  def up
    remove_index :promo_registrations, :channel_id
    add_index :promo_registrations, :channel_id, unique: true
  end

  def down
    add_index :promo_registrations, :channel_id
    remove_index :promo_registrations, :channel_id, unique: true
  end
end
