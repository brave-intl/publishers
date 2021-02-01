class AddBitflyerDepositIdToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_column :publishers, :bitflyer_deposit_id, :string
  end
end
