class AddExpectedNumPaymentsToPayoutReport < ActiveRecord::Migration[5.2]
  def change
    add_column :payout_reports, :expected_num_payments, :integer
  end
end
