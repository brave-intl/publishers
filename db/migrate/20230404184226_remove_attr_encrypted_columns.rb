class RemoveAttrEncryptedColumns < ActiveRecord::Migration[7.0]
  def change
      safety_assured {
        remove_column :bitflyer_connections, :encrypted_access_token_2
        remove_column :bitflyer_connections, :encrypted_access_token_2_iv
        remove_column :bitflyer_connections, :encrypted_refresh_token_2
        remove_column :bitflyer_connections, :encrypted_refresh_token_2_iv

        remove_column :gemini_connections, :encrypted_access_token_2
        remove_column :gemini_connections, :encrypted_access_token_2_iv
        remove_column :gemini_connections, :encrypted_refresh_token_2
        remove_column :gemini_connections, :encrypted_refresh_token_2_iv

        remove_column :stripe_connections, :encrypted_access_token_2
        remove_column :stripe_connections, :encrypted_access_token_2_iv
        remove_column :stripe_connections, :encrypted_refresh_token_2
        remove_column :stripe_connections, :encrypted_refresh_token_2_iv

        remove_column :totp_registrations, :encrypted_secret_2
        remove_column :totp_registrations, :encrypted_secret_2_iv

        remove_column :uphold_connections, :encrypted_uphold_code_2
        remove_column :uphold_connections, :encrypted_uphold_code_2_iv
        remove_column :uphold_connections, :encrypted_uphold_access_parameters_2
        remove_column :uphold_connections, :encrypted_uphold_access_parameters_2_iv

        remove_column :user_authentication_tokens, :encrypted_authentication_token_2
        remove_column :user_authentication_tokens, :encrypted_authentication_token_2_iv
      }

  end
end
