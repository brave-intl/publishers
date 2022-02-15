class RemovePercentCompletion < ActiveRecord::Migration[6.1]
  def change
    remove_column :payout_reports, :percent_complete
  end
end
