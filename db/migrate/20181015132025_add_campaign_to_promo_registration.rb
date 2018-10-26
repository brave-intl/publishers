class AddCampaignToPromoRegistration < ActiveRecord::Migration[5.2]
  def change
    change_table :promo_registrations do |t|
      t.references :promo_campaign, type: :uuid, index: true, null: true, unique: true
    end
  end
end
