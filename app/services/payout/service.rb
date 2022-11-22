# typed: true

module Payout
  class Service
    class WalletError < StandardError; end

    def create_message(payout_report:, publisher:, message:)
      PayoutMessage.create(
        payout_report: payout_report,
        publisher: publisher,
        message: "#{self.class.name} #{message}"
      )
    end

    # Internal: Creates entries for any reason for not paying out a publisher.
    #
    # Returns a boolean
    def skip_publisher?(payout_report:, publisher:, allowed_regions: [], connection: nil)
      if !allowed_regions.blank? && connection.present?
        if !allowed_regions.include?(connection.country&.upcase) && !publisher.may_create_referrals?
          create_message(message: "Publisher's wallet connection is in an unallowed country: #{connection.country&.upcase}. Allowlist: #{allowed_regions}", payout_report: payout_report, publisher: publisher)
          return true
        end
      end

      if !publisher.has_verified_channel?
        create_message(message: "Publisher has no verified channels", payout_report: payout_report, publisher: publisher)
        return true
      end

      if publisher.excluded_from_payout?
        create_message(message: "Publisher has been marked as excluded from payout", payout_report: payout_report, publisher: publisher)
        return true
      end

      if publisher.hold?
        create_message(message: "Publisher is currently in hold status", payout_report: payout_report, publisher: publisher)
        return true
      end

      if publisher.locked?
        create_message(message: "Publisher is currently in lock status", payout_report: payout_report, publisher: publisher)
        return true
      end

      if publisher.wire_only?
        create_message(message: "Publisher is only meant to receive wire transfers", payout_report: payout_report, publisher: publisher)
        return true
      end

      false
    end
  end
end
