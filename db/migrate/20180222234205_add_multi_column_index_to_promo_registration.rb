class AddMultiColumnIndexToPromoRegistration < ActiveRecord::Migration[5.0]
  def change
    add_index :promo_registrations, ["promo_id", "referral_code"], unique: true
  end
end
