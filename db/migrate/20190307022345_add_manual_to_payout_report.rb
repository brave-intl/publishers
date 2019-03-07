class AddManualToPayoutReport < ActiveRecord::Migration[5.2]
  def change
    add_column :payout_reports, :manual, :boolean
  end
end
