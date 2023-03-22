class AddRails7EncryptedColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :bitflyer_connections, :access_token, :text
    add_column :bitflyer_connections, :refresh_token, :text
    add_column :gemini_connections, :access_token, :text
    add_column :gemini_connections, :refresh_token, :text
    add_column :stripe_connections, :access_token, :text
    add_column :stripe_connections, :refresh_token, :text
    add_column :totp_registrations, :secret, :text
    add_column :uphold_connections, :uphold_code, :text
    add_column :uphold_connections, :uphold_access_parameters, :text
    add_column :user_authentication_tokens, :authentication_token, :text
  end
end
