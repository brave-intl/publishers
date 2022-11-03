# typed: true

module Payout
  class BitflyerService < Service
    def self.build
      new(payout_utils_class: Payout::Service)
    end

    def initialize(payout_utils_class:)
      @payout_utils_class = payout_utils_class
    end

    # Change to call as soon as we refactor the other services
    def perform(publisher:, payout_report:, allowed_regions: [])
      return [] if skip_publisher?(payout_report: payout_report, publisher: publisher)

      potential_payments = []

      connection = publisher.bitflyer_connection

      # We don't currently support referrals payouts for Bitflyer accounts, so
      # only payout contributions on channels. To support referrals, we'd need to
      # create a deposit_id on each connection, not just the channels
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
          address: channel.deposit_id || "",
          wallet_provider_id: connection.display_name || "", # this is a hash of the account_id
          wallet_provider: ::PotentialPayment.wallet_providers["bitflyer"],
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
