class AllowBlankChannelIdsOnPromoRegistration < ActiveRecord::Migration[5.2]
  def change
    change_column_null :promo_registrations, :channel_id, true
  end
end
