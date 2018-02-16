class AddMarketingEmailOptOutFlagToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :marketing_opt_out, :boolean, :default => false
  end
end
