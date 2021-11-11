# typed: ignore
class AddReferralCodeIndexToPromoRegistration < ActiveRecord::Migration[6.0]
  def change
    add_index :promo_registrations, :referral_code
  end
end
