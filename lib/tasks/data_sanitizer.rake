# frozen_string_literal: true

# Sanitize legacy data (pre multi-channel)
namespace :data_sanitizer do
  task sanitize: :environment do
    raise "Don't run this in prod." if Rails.env.production?

    PublisherStatement.update_all source_url: "https://redacted-source-url.local"
    Publisher.find_each do |publisher|
      email_digest = publisher.email \
        && Digest::SHA2.hexdigest(publisher.email)[0..32]
      auth_user_id = publisher.auth_user_id \
        && Digest::SHA2.hexdigest(publisher.auth_user_id)[0..32]
      auth_email_digest = publisher.auth_email \
        && Digest::SHA2.hexdigest(publisher.auth_email)[0..32]
      publisher.update_columns(
        encrypted_authentication_token: nil,
        encrypted_authentication_token_iv: nil,
        name: "User #{Random.rand(10_000)}",
        email: email_digest && "publishers-staging+2+#{email_digest}@basicattentiontoken.org",
        phone: nil,
        phone_normalized: nil,
        uphold_state_token: nil,
        encrypted_uphold_code: nil,
        encrypted_uphold_code_iv: nil,
        encrypted_uphold_access_parameters: nil,
        encrypted_uphold_access_parameters_iv: nil,
        uphold_verified: false,
        auth_user_id: auth_user_id,
        auth_name: "User #{Random.rand(10_000)}",
        auth_email: auth_email_digest && "publishers-staging+2+#{auth_email_digest}@basicattentiontoken.org",
        uphold_updated_at: nil
      )
      STDOUT << "."
    end
    # encrypted_secret is environment specific, and we're not going to load prod
    # decryption keys into staging or dev
    TotpRegistration.delete_all
    PaperTrail::Version.delete_all
  end
end
