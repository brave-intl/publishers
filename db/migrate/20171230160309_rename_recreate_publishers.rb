class RenameRecreatePublishers < ActiveRecord::Migration[5.0]
  def change
    rename_table :publishers, :legacy_publishers
    rename_table :youtube_channels, :legacy_youtube_channels

    create_table :publishers, id: :uuid do |t|
      t.string :name, null: :false
      t.string :email
      t.string :pending_email
      t.string :phone
      t.string :phone_normalized
      t.string :encrypted_authentication_token
      t.string :encrypted_authentication_token_iv
      t.datetime :authentication_token_expires_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip
      t.boolean :created_via_api, default: false, null: false
      t.string :default_currency
      t.string :uphold_state_token
      t.boolean :uphold_verified, default: false
      t.string :encrypted_uphold_code
      t.string :encrypted_uphold_code_iv
      t.string :encrypted_uphold_access_parameters
      t.string :encrypted_uphold_access_parameters_iv
      t.datetime :uphold_updated_at
      t.boolean :uphold_verified, default: false

      t.timestamps
      t.index :email, unique: true
      t.index :pending_email
      t.index :created_at
    end
  end
end