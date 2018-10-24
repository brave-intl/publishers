class AddKindToPromoRegistration < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_registrations, :kind, :text
  end
end