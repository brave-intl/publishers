class AddVerifiedAtToChannel < ActiveRecord::Migration[5.0]
  def change
    add_column :channels, :verified_at, :timestamp
  end
end
