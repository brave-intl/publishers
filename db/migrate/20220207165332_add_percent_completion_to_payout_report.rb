class AddPercentCompletionToPayoutReport < ActiveRecord::Migration[6.1]
  def change
    add_column :payout_reports, :percent_complete, :float, default: 0
  end
end
