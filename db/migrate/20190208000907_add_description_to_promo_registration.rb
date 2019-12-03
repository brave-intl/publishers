class AddDescriptionToPromoRegistration < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_registrations, :description, :string
  end
end
