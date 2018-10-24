class AddActiveToPromoRegistration < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_registrations, :active, :bool, null: false, default: true
  end
end