class AddChannelTypeToPotentialPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :channel_type, :text
  end
end
