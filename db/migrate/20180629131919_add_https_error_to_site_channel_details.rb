class AddHttpsErrorToSiteChannelDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :site_channel_details, :https_error, :string
  end
end
