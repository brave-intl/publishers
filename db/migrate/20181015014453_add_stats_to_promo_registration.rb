class AddStatsToPromoRegistration < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_registrations, :stats, :jsonb, default: '{}'
  end
end
