# typed: true

module Payout
  class GeminiService < Service
    def perform(payout_report:, publisher:, allowed_regions: [])
      potential_payments = []
      connection = publisher.gemini_connection
      return [] if skip_publisher?(payout_report: payout_report, publisher: publisher, allowed_regions: allowed_regions, connection: connection)

      if publisher.may_create_referrals?
        potential_payments << PotentialPayment.new(
          payout_report_id: payout_report&.id,
          name: publisher.name,
          amount: "0",
          fees: "0",
          publisher_id: publisher.id,
          kind: ::PotentialPayment::REFERRAL,
          gemini_is_verified: connection.payable?,
          address: connection.recipient_id || "",
          wallet_provider_id: connection.wallet_provider_id,
          wallet_provider: ::PotentialPayment.wallet_providers["gemini"],
          suspended: publisher.suspended?,
          whitelisted: publisher.whitelisted?,
          status: publisher.last_status_update&.status
        )
      end

      publisher.channels.verified.each do |channel|
        potential_payments << PotentialPayment.new(
          payout_report_id: payout_report&.id,
          name: channel.publication_title.to_s,
          amount: "0",
          fees: "0",
          publisher_id: publisher.id,
          channel_id: channel.id,
          kind: ::PotentialPayment::CONTRIBUTION,
          url: channel.details.url.to_s,
          address: connection.wallet_provider_id || "",
          gemini_is_verified: connection.payable?,
          wallet_provider_id: connection.wallet_provider_id,
          wallet_provider: ::PotentialPayment.wallet_providers["gemini"],
          suspended: publisher.suspended?,
          whitelisted: publisher.whitelisted?,
          status: publisher.last_status_update&.status,
          channel_stats: channel.details.stats,
          channel_type: channel.details_type
        )
      end

      potential_payments
    end
  end
end
