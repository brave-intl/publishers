# typed: ignore
class AddPayerIdToPaypalConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :paypal_connections, :payer_id, :text
  end
end
