class AddPropertiesToUpholdConnection < ActiveRecord::Migration[5.2]
  def change
    add_column :uphold_connections, :status, :string
    add_column :uphold_connections, :default_currency, :string
    add_column :uphold_connections, :default_currency_confirmed_at, :datetime
  end
end
