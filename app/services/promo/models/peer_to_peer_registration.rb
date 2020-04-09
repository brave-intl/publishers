require 'addressable/template'
require 'json'

module Promo
  module Models
    class PeerToPeerRegistration < Client
      # For more information about how these URI templates are structured read the explaination in the RFC
      # https://www.rfc-editor.org/rfc/rfc6570.txt
      PATH = Addressable::Template.new("api/2/promo/referral_code/p2p/{id}")

      # Creates a new owner
      # @param [String] id The owner identifier
      def create(publisher:, promo_campaign:)
        return perform_offline(publisher: publisher) if Rails.application.secrets[:api_promo_base_uri].blank?
        response = put(PATH.expand(id: publisher.owner_identifier))
        payload = JSON.parse(response.body)
        payload.each do |promo_registration|
          PromoRegistration.create!(
            referral_code: promo_registration["referral_code"],
            publisher_id: publisher.id,
            promo_id: Rails.application.secrets[:active_promo_id],
            promo_campaign_id: promo_campaign.id,
            kind: PromoRegistration::PEER_TO_PEER
          )
        end
      end

      def offline_promo
        "BAT4U"
      end

      def perform_offline(publisher:)
        # Already has a unique validation
        promo_registration = PromoRegistration.find_by(referral_code: offline_promo)
        return promo_registration if promo_registration.present?
        PromoRegistration.create!(
          referral_code: offline_promo,
          publisher_id: publisher.id,
          promo_id: Rails.application.secrets[:active_promo_id],
          promo_campaign_id: PromoCampaign.find_by(name: PromoCampaign::PEER_TO_PEER).id,
          kind: PromoRegistration::PEER_TO_PEER
        )
      end
    end
  end
end
