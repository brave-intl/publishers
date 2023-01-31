# typed: ignore
# frozen_string_literal: true

module TwoFactorAuth
  class WebauthnRegistrationService < BuilderBaseService
    def self.build
      new(webauthn_credentialer: WebAuthn::Credential)
    end

    def initialize(webauthn_credentialer:)
      @webauthn_credentialer = webauthn_credentialer
    end

    def call(publisher:, webauthn_response:, challenge:, name:)
      response = JSON.parse(webauthn_response)
      credential = @webauthn_credentialer.from_create(response)

      begin
        credential.verify(challenge)
      rescue WebAuthn::Error => e
        Rails.logger.debug("Webauthn::Error! #{e}")
        return problem(e.message)
      end

      publisher.u2f_registrations.create!(
        {
          key_handle: credential.id,
          public_key: credential.public_key,
          counter: credential.sign_count,
          name: name,
          format: U2fRegistration.formats[:webauthn]
        }
      )

      pass
    end
  end
end
