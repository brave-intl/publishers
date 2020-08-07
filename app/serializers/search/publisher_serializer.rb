module Search
  class PublisherSerializer < ActiveModel::Serializer
    attributes :id, :owner_identifier, :email, :name, :channel_identifiers, :channel_titles, :referral_codes

    def channel_identifiers
      object.channels.verified.collect do |channel|
        channel.details.channel_identifier
      end
    end

    def channel_titles
      object.channels.verified.collect do |channel|
        channel.details.publication_title
      end
    end

    def referral_codes
      object.channels.verified.collect do |channel|
        channel.promo_registration&.referral_code
      end
    end
  end
end
