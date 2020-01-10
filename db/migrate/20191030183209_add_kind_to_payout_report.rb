class AddKindToPayoutReport < ActiveRecord::Migration[6.0]
  def change
    add_column :payout_reports, :kind, :string, default: PayoutReport::UPHOLD
  end
end
