module LegacyData
  class LegacyU2fRegistration < ActiveRecord::Base
    belongs_to :legacy_publisher, foreign_key: :publisher_id
  end

  class LegacyTotpRegistration < ActiveRecord::Base
    belongs_to :legacy_publisher, foreign_key: :publisher_id
    attr_encrypted :secret, key: :encryption_key

    def totp
      ROTP::TOTP.new(secret, issuer: totp_issuer)
    end

    def encryption_key
      self.class.encryption_key
    end

    class << self
      def encryption_key
        Rails.application.secrets[:attr_encrypted_key]
      end
    end

    private

    def totp_issuer
      issuer = "Brave Payments"

      environment = Rails.env
      if %w(development staging).include?(environment)
        issuer += " (#{environment.capitalize})"
      end

      issuer
    end
  end

  class LegacyYoutubeChannel < ActiveRecord::Base
  end

  class LegacyPublisher < ActiveRecord::Base
    attr_encrypted :authentication_token, key: :encryption_key
    attr_encrypted :uphold_code, key: :encryption_key
    attr_encrypted :uphold_access_parameters, key: :encryption_key

    belongs_to :legacy_youtube_channel, foreign_key: :youtube_channel_id
    has_many :legacy_u2f_registrations, -> { order("created_at DESC") }, foreign_key: :publisher_id
    has_one :legacy_totp_registration, foreign_key: :publisher_id

    scope :email_verified, -> {where.not(email: nil)}

    scope :verified_sites, ->(email:) {where(email: email, verified: true, youtube_channel_id: nil).where.not(brave_publisher_id: nil)}
    scope :unverified_sites, ->(email:) {where(email: email, verified: false, youtube_channel_id: nil).where.not(brave_publisher_id: nil)}

    scope :verified_youtube, ->(email:) {where(email: email, verified: true, brave_publisher_id: nil).where.not(youtube_channel_id: nil)}

    def encryption_key
      Rails.application.secrets[:attr_encrypted_key]
    end
  end
end