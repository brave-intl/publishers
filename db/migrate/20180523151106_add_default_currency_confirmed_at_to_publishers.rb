class AddDefaultCurrencyConfirmedAtToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :default_currency_confirmed_at, :datetime
  end
end