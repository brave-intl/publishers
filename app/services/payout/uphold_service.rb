# typed: true
module Payout
  class UpholdService < Service
    def perform(payout_report:, publisher:)
      return [] if skip_publisher?(payout_report: payout_report, publisher: publisher)

      potential_payments = []
      uphold_connection = publisher.uphold_connection

      # Create the referral payment for the owner
      if publisher.may_create_referrals?
        potential_payments << PotentialPayment.new(
          payout_report_id: payout_report&.id,
          name: publisher.name,
          amount: "0",
          fees: "0",
          publisher_id: publisher.id,
          kind: ::PotentialPayment::REFERRAL,
          address: uphold_connection.address.to_s,
          uphold_status: uphold_connection.status,
          reauthorization_needed: uphold_connection.uphold_access_parameters.blank?,
          uphold_member: uphold_connection.is_member?,
          uphold_id: uphold_connection.uphold_id,
          wallet_provider_id: uphold_connection.uphold_id,
          wallet_provider: ::PotentialPayment.wallet_providers["uphold"],
          suspended: publisher.suspended?,
          status: publisher.last_status_update&.status
        )
      end

      # Create potential payments for channel contributions
      publisher.channels.verified.each do |channel|
        potential_payments << PotentialPayment.new(
          payout_report_id: payout_report&.id,
          name: channel.publication_title.to_s,
          amount: "0",
          fees: "0",
          publisher_id: publisher.id,
          channel_id: channel.id,
          kind: ::PotentialPayment::CONTRIBUTION,
          address: uphold_connection.address.to_s,
          url: channel.details.url.to_s,
          uphold_status: uphold_connection.status,
          reauthorization_needed: uphold_connection.uphold_access_parameters.blank?,
          uphold_member: uphold_connection.is_member?,
          uphold_id: uphold_connection.uphold_id,
          wallet_provider_id: uphold_connection.uphold_id,
          wallet_provider: ::PotentialPayment.wallet_providers["uphold"],
          suspended: publisher.suspended?,
          status: publisher.last_status_update&.status,
          channel_stats: channel.details.stats,
          channel_type: channel.details_type
        )
      end

      potential_payments
    rescue => e
      PayoutMessage.create(payout_report: payout_report, publisher: publisher, message: e.message)
      raise e
    end
  end
end
