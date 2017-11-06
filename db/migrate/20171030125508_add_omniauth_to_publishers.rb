class AddOmniauthToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :auth_provider, :string
    add_column :publishers, :auth_user_id, :string
    add_column :publishers, :auth_name, :string
    add_column :publishers, :auth_email, :string
  end
end
