class RemoveContentsFromPayoutReports < ActiveRecord::Migration[6.1]
  def up
    remove_column :payout_reports, :encrypted_contents
    remove_column :payout_reports, :encrypted_contents_iv
  end

  def down
    add_column :payout_reports, :encrypted_contents, :text
    add_column :payout_reports, :encrypted_contents_iv, :text
  end
end
