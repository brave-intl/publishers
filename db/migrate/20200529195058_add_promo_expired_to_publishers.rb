class AddPromoExpiredToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_column :publishers, :promo_expiration_time, :datetime
  end
end
