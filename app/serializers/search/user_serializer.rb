module Search
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :email, :name, :referral_codes, :wallet_identifiers, :created_at,
               :channel_identifiers, :channel_titles, :channel_urls

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
      [
        object.paypal_connection&.paypal_account_id,
        object.uphold_connection&.uphold_id,
      ]
    end

    private

    def verified_channels
      @channels ||= object.channels.verified
    end
  end
end
