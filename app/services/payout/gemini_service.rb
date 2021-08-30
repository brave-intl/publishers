module Payout
  class GeminiService
    def perform
      return [] if Payout::Service.new(class_name: self,
                                       payout_report: payout_report,
                                       publisher: publisher).skip_publisher?

      potential_payments = []
      connection = publisher.gemini_connection

      if publisher.may_create_referrals?
        potential_payments << PotentialPayment.new(
          payout_report_id: payout_report&.id,
          name: publisher.name,
          amount: "0",
          fees: "0",
          publisher_id: publisher.id,
          kind: ::PotentialPayment::REFERRAL,
          gemini_is_verified: connection.payable?,
          address: connection.recipient_id || '',
          wallet_provider_id: connection.recipient_id,
          wallet_provider: ::PotentialPayment.wallet_providers['gemini'],
          suspended: publisher.suspended?,
          status: publisher.last_status_update&.status
        )
      end

      publisher.channels.verified.each do |channel|
        potential_payments << PotentialPayment.new(
          payout_report_id: payout_report&.id,
          name: "#{channel.publication_title}",
          amount: "0",
          fees: "0",
          publisher_id: publisher.id,
          channel_id: channel.id,
          kind: ::PotentialPayment::CONTRIBUTION,
          url: "#{channel.details.url}",
          address: connection.recipient_id || '',
          gemini_is_verified: connection.payable?,
          wallet_provider_id: connection.recipient_id,
          wallet_provider: ::PotentialPayment.wallet_providers['gemini'],
          suspended: publisher.suspended?,
          status: publisher.last_status_update&.status,
          channel_stats: channel.details.stats,
          channel_type: channel.details_type
        )
      end

      potential_payments
    end
  end
end
