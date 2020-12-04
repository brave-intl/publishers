module Payout
  class UpholdService < Service
    # 5 BAT
    PROBI_THRESHOLD = 5 * 1E18

    def perform
      return if skip_publisher?

      potential_payments = []
      uphold_connection = @publisher.uphold_connection

      uphold_connection.sync_connection!
      if uphold_connection.missing_card?
        uphold_connection.create_uphold_cards
        # Reload the connection because create_uphold_cards modifies the database records.
        uphold_connection.reload
      end

      # Create the referral payment for the owner
      potential_payments << PotentialPayment.new(
        payout_report_id: @payout_report&.id,
        name: @publisher.name,
        amount: "0",
        fees: "0",
        publisher_id: @publisher.id,
        kind: ::PotentialPayment::REFERRAL,
        address: "#{uphold_connection.address}",
        uphold_status: uphold_connection.status,
        reauthorization_needed: uphold_connection.uphold_access_parameters.blank?,
        uphold_member: uphold_connection.is_member?,
        uphold_id: uphold_connection.uphold_id,
        wallet_provider_id: uphold_connection.uphold_id,
        wallet_provider: ::PotentialPayment.wallet_providers['uphold'],
        suspended: @publisher.suspended?,
        status: @publisher.last_status_update&.status
      )

      # Create potential payments for channel contributions
      @publisher.channels.verified.each do |channel|
        potential_payments << PotentialPayment.new(
          payout_report_id: @payout_report&.id,
          name: "#{channel.publication_title}",
          amount: "0",
          fees: "0",
          publisher_id: @publisher.id,
          channel_id: channel.id,
          kind: ::PotentialPayment::CONTRIBUTION,
          address: "#{uphold_connection.address}",
          url: "#{channel.details.url}",
          uphold_status: uphold_connection.status,
          reauthorization_needed: uphold_connection.uphold_access_parameters.blank?,
          uphold_member: uphold_connection.is_member?,
          uphold_id: uphold_connection.uphold_id,
          wallet_provider_id: uphold_connection.uphold_id,
          wallet_provider: ::PotentialPayment.wallet_providers['uphold'],
          suspended: @publisher.suspended?,
          status: @publisher.last_status_update&.status,
          channel_stats: channel.details.stats,
          channel_type: channel.details_type
        )
      end

      unless should_only_notify?
        potential_payments.each do |payment|
          unless payment.save
            # If the payment couldn't save then we created a PayoutMessage
            PayoutMessage.create(
              payout_report: @payout_report,
              publisher: @publisher,
              message: "Could not save the potential_payment: #{payment.errors&.full_messages&.join(', ')}"
            )
          end
        end
      end

      # Notify publishers that have money waiting, but will not will not receive funds
=begin
      # (yachtcaptain23): TODO: https://github.com/brave-intl/publishers/issues/2967
      if should_send_emails?(total_probi: total_probi, uphold_connection: uphold_connection)
        send_emails(uphold_connection, probi_to_bat(total_probi).round(1))
      end
=end
    rescue StandardError => e
      PayoutMessage.create(payout_report: @payout_report, publisher: @publisher, message: e.message) unless should_only_notify?

      raise e
    end

    private

    def send_emails(uphold_connection, total_amount)
      if !uphold_connection.uphold_verified? || uphold_connection.status.blank?
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are disconnected from Uphold.")
        PublisherMailer.wallet_not_connected(@publisher, total_amount).deliver_later
        uphold_connection.update(send_emails: 1.year.from_now)
      end

      # eyeshade omits the wallet address if the status is not ok
      # means that the transaction limits have been exceeded
      if uphold_connection.is_member? && uphold_connection.status != "ok"
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are restricted on Uphold.")
        PublisherMailer.uphold_member_restricted(@publisher).deliver_later
        uphold_connection.update(send_emails: 1.year.from_now)
      end

      # The wallet's uphold account status has to exist because otherwise their wallet is just not connected
      if uphold_connection.uphold_verified? && uphold_connection.status.present? && !uphold_connection.is_member?
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are not a verified member on Uphold")
        PublisherMailer.uphold_kyc_incomplete(@publisher, total_amount).deliver_later
        uphold_connection.update(send_emails: 1.year.from_now)
      end
    end


    def should_send_emails?(total_probi:, uphold_connection:)
      total_probi > PROBI_THRESHOLD && @should_send_notifications &&
        (
          uphold_connection.send_emails.present? &&
          uphold_connection.send_emails < DateTime.now &&
          uphold_connection.send_emails != UpholdConnection::FOREVER_DATE
        )
    end

    # Converts Probi to BAT, original implementation Eyeshade::BaseBalance
    def probi_to_bat(probi)
      probi.to_d / 1E18
    end
  end
end
