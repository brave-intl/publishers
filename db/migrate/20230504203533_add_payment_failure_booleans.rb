class AddPaymentFailureBooleans < ActiveRecord::Migration[7.0]
  def change
    add_column :uphold_connections, :payout_failed, :boolean, default: false, null: false
    add_column :gemini_connections, :payout_failed, :boolean, default: false, null: false
    add_column :bitflyer_connections, :payout_failed, :boolean, default: false, null: false
  end
end
