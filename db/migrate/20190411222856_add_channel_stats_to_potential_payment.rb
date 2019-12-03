class AddChannelStatsToPotentialPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :potential_payments, :channel_stats, :jsonb, default: {}
  end
end
