class AddPublisherToPromoRegistration < ActiveRecord::Migration[5.2]
  def change
    add_reference :promo_registrations, :publisher, type: :uuid, index: true
  end
end
