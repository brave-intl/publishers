class AddEncryptedColumnToAllTables < ActiveRecord::Migration[7.0]
  def change
    add_column :bitflyer_connections, :encrypted_access_token_2, :string
    add_column :bitflyer_connections, :encrypted_access_token_2_iv, :string
    add_column :bitflyer_connections, :encrypted_refresh_token_2, :string
    add_column :bitflyer_connections, :encrypted_refresh_token_2_iv, :string

    add_column :gemini_connections, :encrypted_access_token_2, :string
    add_column :gemini_connections, :encrypted_access_token_2_iv, :string
    add_column :gemini_connections, :encrypted_refresh_token_2, :string
    add_column :gemini_connections, :encrypted_refresh_token_2_iv, :string

    add_column :stripe_connections, :encrypted_access_token_2, :string
    add_column :stripe_connections, :encrypted_access_token_2_iv, :string
    add_column :stripe_connections, :encrypted_refresh_token_2, :string
    add_column :stripe_connections, :encrypted_refresh_token_2_iv, :string

    add_column :totp_registrations, :encrypted_secret_2, :string
    add_column :totp_registrations, :encrypted_secret_2_iv, :string


    add_column :uphold_connections, :encrypted_uphold_code_2, :string
    add_column :uphold_connections, :encrypted_uphold_code_2_iv, :string
    add_column :uphold_connections, :encrypted_uphold_access_parameters_2, :string
    add_column :uphold_connections, :encrypted_uphold_access_parameters_2_iv, :string


    add_column :user_authentication_tokens, :encrypted_authentication_token_2, :string
    add_column :user_authentication_tokens, :encrypted_authentication_token_2_iv, :string
  end
end
