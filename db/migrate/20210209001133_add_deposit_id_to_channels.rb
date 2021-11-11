# typed: ignore
class AddDepositIdToChannels < ActiveRecord::Migration[6.0]
  def change
    add_column :channels, :deposit_id, :string
  end
end
