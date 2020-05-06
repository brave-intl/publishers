require 'addressable/template'
require 'json'

module Promo
  module Models
    class PeerToPeerRegistration < Client

      # Creates a new owner
      # @param [String] id The owner identifier
      def create(publisher:, promo_campaign:)
        return perform_offline(publisher: publisher) if Rails.application.secrets[:api_promo_base_uri].blank?
        connection ||= begin
          require "faraday"
          Faraday.new(url: Rails.application.secrets[:api_promo_base_uri] + "api/2/promo/referral_code/p2p/#{publisher.owner_identifier}" + "?cap=1000") do |faraday|
            faraday.request :retry, max: 2, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2
            faraday.response(:logger, Rails.logger, bodies: true, headers: true)
            faraday.use(Faraday::Response::RaiseError)
            faraday.adapter Faraday.default_adapter
          end
        end

        connection.send(:put) do |req|
          req.headers["Authorization"] = "Bearer #{Rails.application.secrets[:api_promo_key]}"
          req.headers['Content-Type'] = 'application/json'
        end

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
