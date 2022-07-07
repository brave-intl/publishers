class AddLimitToPublisher < ActiveRecord::Migration[6.1]
  def change
    add_column :publishers, :site_channel_limit, :integer, default: 2 
  end
end
