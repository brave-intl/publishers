module Search
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :email, :name, :referral_codes, :wallet_identifiers, :created_at,
               :channel_identifiers, :channel_titles, :channel_urls, :status

    def channel_identifiers
      verified_channels.collect { |c| c.details.channel_identifier }
    end

    def channel_titles
      verified_channels.collect { |c| c.details.publication_title }
    end

    def channel_urls
      verified_channels.collect { |c| c.details.url }
    end

    def referral_codes
      verified_channels.collect do |channel|
        channel.promo_registration&.referral_code
      end
    end

    def wallet_identifiers
      [object.gemini_connection, object.paypal_connection, object.uphold_connection].
        map { |w| w&.wallet_provider_id }
    end

    def status
      object.last_status_update&.status
    end

    private

    def verified_channels
      @channels ||= object.channels.verified
    end
  end
end
