class RemoveContentsFromPayoutReports < ActiveRecord::Migration[6.0]
  def change
    remove_column :payout_reports, :encrypted_contents
    remove_column :payout_reports, :encrypted_contents_iv
  end
end
