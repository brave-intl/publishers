class AddTransferToChannelOnChannelTransfers < ActiveRecord::Migration[5.2]
  def change
    add_reference :channel_transfers, :transfer_to_channel, index: true, type: :uuid, null: :false
  end
end
