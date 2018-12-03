class RemoveAmountAndFeesFromPayoutReport < ActiveRecord::Migration[5.2]
  def change
    remove_column :payout_reports, :fees
    remove_column :payout_reports, :amount
    remove_column :payout_reports, :num_payments
  end
end