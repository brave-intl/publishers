class CopyEncryptedColumnsOnAllTables < ActiveRecord::Migration[7.0]
  def up
    # Bitflyer
    BitflyerConnection.update_all("encrypted_access_token_2=encrypted_access_token")
    BitflyerConnection.update_all("encrypted_access_token_2_iv=encrypted_access_token_iv")
    BitflyerConnection.update_all("encrypted_refresh_token_2=encrypted_refresh_token")
    BitflyerConnection.update_all("encrypted_refresh_token_2_iv=encrypted_refresh_token_iv")
    
    safety_assured {
      remove_column :bitflyer_connections, :encrypted_access_token
      remove_column :bitflyer_connections, :encrypted_access_token_iv
      remove_column :bitflyer_connections, :encrypted_refresh_token
      remove_column :bitflyer_connections, :encrypted_refresh_token_iv
    }

    # Gemini
    GeminiConnection.update_all("encrypted_access_token_2=encrypted_access_token")
    GeminiConnection.update_all("encrypted_access_token_2_iv=encrypted_access_token_iv")
    GeminiConnection.update_all("encrypted_refresh_token_2=encrypted_refresh_token")
    GeminiConnection.update_all("encrypted_refresh_token_2_iv=encrypted_refresh_token_iv")

    safety_assured {
      remove_column :gemini_connections, :encrypted_access_token
      remove_column :gemini_connections, :encrypted_access_token_iv
      remove_column :gemini_connections, :encrypted_refresh_token
      remove_column :gemini_connections, :encrypted_refresh_token_iv
    }

    # Stripe
    StripeConnection.update_all("encrypted_access_token_2=encrypted_access_token")
    StripeConnection.update_all("encrypted_access_token_2_iv=encrypted_access_token_iv")
    StripeConnection.update_all("encrypted_refresh_token_2=encrypted_refresh_token")
    StripeConnection.update_all("encrypted_refresh_token_2_iv=encrypted_refresh_token_iv")

    safety_assured {
      remove_column :stripe_connections, :encrypted_access_token
      remove_column :stripe_connections, :encrypted_access_token_iv
      remove_column :stripe_connections, :encrypted_refresh_token
      remove_column :stripe_connections, :encrypted_refresh_token_iv
    }

    # Totp
    TotpRegistration.update_all("encrypted_secret_2=encrypted_secret")
    TotpRegistration.update_all("encrypted_secret_2_iv=encrypted_secret_iv")
    safety_assured {
      remove_column :totp_registrations, :encrypted_secret
      remove_column :totp_registrations, :encrypted_secret_iv
    }

    # Uphold
    UpholdConnection.update_all("encrypted_uphold_code_2=encrypted_uphold_code")
    UpholdConnection.update_all("encrypted_uphold_code_2_iv=encrypted_uphold_code_iv")
    UpholdConnection.update_all("encrypted_uphold_access_parameters_2=encrypted_uphold_access_parameters")
    UpholdConnection.update_all("encrypted_uphold_access_parameters_2_iv=encrypted_uphold_access_parameters_iv")

    safety_assured {
      remove_column :uphold_connections, :encrypted_uphold_code
      remove_column :uphold_connections, :encrypted_uphold_code_iv
      remove_column :uphold_connections, :encrypted_uphold_access_parameters
      remove_column :uphold_connections, :encrypted_uphold_access_parameters_iv
    }

    # UserAuthenticationToken
    UserAuthenticationToken.update_all("encrypted_authentication_token_2=encrypted_authentication_token")
    UserAuthenticationToken.update_all("encrypted_authentication_token_2_iv=encrypted_authentication_token_iv")

    safety_assured {
      remove_column :user_authentication_tokens, :encrypted_authentication_token
      remove_column :user_authentication_tokens, :encrypted_authentication_token_iv
    }
  end

  def down
    add_column :bitflyer_connections, :encrypted_access_token, :string
    add_column :bitflyer_connections, :encrypted_access_token_iv, :string
    add_column :bitflyer_connections, :encrypted_refresh_token, :string
    add_column :bitflyer_connections, :encrypted_refresh_token_iv, :string
    BitflyerConnection.update_all("encrypted_access_token=encrypted_access_token_2")
    BitflyerConnection.update_all("encrypted_access_token_iv=encrypted_access_token_2_iv")
    BitflyerConnection.update_all("encrypted_refresh_token=encrypted_refresh_token_2")
    BitflyerConnection.update_all("encrypted_refresh_token_iv=encrypted_refresh_token_2_iv")

    add_column :gemini_connections, :encrypted_access_token, :string
    add_column :gemini_connections, :encrypted_access_token_iv, :string
    add_column :gemini_connections, :encrypted_refresh_token, :string
    add_column :gemini_connections, :encrypted_refresh_token_iv, :string
    GeminiConnection.update_all("encrypted_access_token=encrypted_access_token_2")
    GeminiConnection.update_all("encrypted_access_token_iv=encrypted_access_token_2_iv")
    GeminiConnection.update_all("encrypted_refresh_token=encrypted_refresh_token_2")
    GeminiConnection.update_all("encrypted_refresh_token_iv=encrypted_refresh_token_2_iv")

    add_column :stripe_connections, :encrypted_access_token, :string
    add_column :stripe_connections, :encrypted_access_token_iv, :string
    add_column :stripe_connections, :encrypted_refresh_token, :string
    add_column :stripe_connections, :encrypted_refresh_token_iv, :string
    StripeConnection.update_all("encrypted_access_token=encrypted_access_token_2")
    StripeConnection.update_all("encrypted_access_token_iv=encrypted_access_token_2_iv")
    StripeConnection.update_all("encrypted_refresh_token=encrypted_refresh_token_2")
    StripeConnection.update_all("encrypted_refresh_token_iv=encrypted_refresh_token_2_iv")

    add_column :totp_registrations, :encrypted_secret, :string
    add_column :totp_registrations, :encrypted_secret_iv, :string
    TotpRegistration.update_all("encrypted_secret=encrypted_secret_2")
    TotpRegistration.update_all("encrypted_secret_iv=encrypted_secret_2_iv")

    add_column :uphold_connections, :encrypted_uphold_code, :string
    add_column :uphold_connections, :encrypted_uphold_code_iv, :string
    add_column :uphold_connections, :encrypted_uphold_access_parameters, :string
    add_column :uphold_connections, :encrypted_uphold_access_parameters_iv, :string
    UpholdConnection.update_all("encrypted_uphold_code=encrypted_uphold_code_2")
    UpholdConnection.update_all("encrypted_uphold_code_iv=encrypted_uphold_code_iv_2")
    UpholdConnection.update_all("encrypted_uphold_access_parameters_iv=encrypted_uphold_access_parameters_2_iv")
    UpholdConnection.update_all("encrypted_uphold_access_parameters=encrypted_uphold_access_parameters_2")


    add_column :user_authentication_tokens, :encrypted_authentication_token, :string
    add_column :user_authentication_tokens, :encrypted_authentication_token_iv, :string
    UserAuthenticationToken.update_all("encrypted_authentication_token=encrypted_authentication_token_2")
    UserAuthenticationToken.update_all("encrypted_authentication_token_iv=encrypted_authentication_token_2_iv")
  end
end
