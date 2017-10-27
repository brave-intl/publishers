class AddDefaultCurrencyToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.string :default_currency, nil: true, default: nil
    end
  end
end
