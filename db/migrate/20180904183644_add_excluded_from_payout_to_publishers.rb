class AddExcludedFromPayoutToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :excluded_from_payout, :boolean, null: false, default: false
  end
end
