class AddPublisherToPromoRegistration < ActiveRecord::Migration[5.2]
  def change
    add_reference :promo_registrations, :publisher, type: :uuid, index: true, foreign_key: true
  end
end
