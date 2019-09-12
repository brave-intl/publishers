class AddIndexToNames < ActiveRecord::Migration[5.2]
  # Reference: https://thoughtbot.com/blog/how-to-create-postgres-indexes-concurrently-in
  disable_ddl_transaction!

  def change
    add_index :site_channel_details, :brave_publisher_id, algorithm: :concurrently
    add_index :promo_registrations, :referral_code, algorithm: :concurrently
    add_index :youtube_channel_details, :title, algorithm: :concurrently
    add_index :twitch_channel_details, :name, algorithm: :concurrently
    add_index :publishers, :name, algorithm: :concurrently
  end
end
