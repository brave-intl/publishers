class AddStatusToPayoutReport < ActiveRecord::Migration[6.1]
  def change
    add_column :payout_reports, :status, :string
  end
end
