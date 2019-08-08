class PayoutReportPublisherIncluder < BaseService
  def initialize(payout_report:, publisher:, should_send_notifications:)
    @publisher = publisher
    @payout_report = payout_report
    @should_send_notifications = should_send_notifications
  end

  def perform
    return if !@publisher.has_verified_channel? || @publisher.locked? || @publisher.excluded_from_payout? || @publisher.hold?

    wallet = PublisherWalletGetter.new(publisher: @publisher).perform
    uphold_connection = @publisher.uphold_connection
    suspended = @publisher.suspended?

    uphold_connection.sync_from_uphold!
    if uphold_connection.missing_card?
      uphold_connection.create_uphold_card_for_default_currency
    end

    probi = wallet.referral_balance.amount_probi # probi = balance
    publisher_has_unsettled_balance = probi.to_i.positive?

    # Create the referral payment for the owner
    unless should_only_notify?
      PotentialPayment.create(
        payout_report_id: @payout_report.id,
        name: @publisher.name,
        amount: "#{probi}",
        fees: "0",
        publisher_id: @publisher.id,
        kind: PotentialPayment::REFERRAL,
        address: "#{uphold_connection.address}",
        uphold_status: uphold_connection.status,
        reauthorization_needed: uphold_connection.uphold_access_parameters.blank?,
        uphold_member: uphold_connection.is_member?,
        uphold_id: uphold_connection.uphold_id,
        suspended: suspended,
        status: @publisher.last_status_update&.status
      )
    end

    # Create potential payments for channel contributions
    @publisher.channels.verified.each do |channel|
      publisher_has_unsettled_balance ||= probi.positive?

      probi = wallet.channel_balances[channel.details.channel_identifier].amount_probi # probi = balance - fee
      fee_probi = wallet.channel_balances[channel.details.channel_identifier].fees_probi # fee = balance - probi

      unless should_only_notify?
        PotentialPayment.create(
          payout_report_id: @payout_report.id,
          name: "#{channel.publication_title}",
          amount: "#{probi}",
          fees: "#{fee_probi}",
          publisher_id: @publisher.id,
          channel_id: channel.id,
          kind: PotentialPayment::CONTRIBUTION,
          address: "#{uphold_connection.address}",
          url: "#{channel.details.url}",
          uphold_status: uphold_connection.status,
          reauthorization_needed: uphold_connection.uphold_access_parameters.blank?,
          uphold_member: uphold_connection.is_member?,
          uphold_id: uphold_connection.uphold_id,
          suspended: suspended,
          status: @publisher.last_status_update&.status,
          channel_stats: channel.details.stats,
          channel_type: channel.details_type
        )
      end
    end

    # Notify publishers that have money waiting, but will not will not receive funds
    if publisher_has_unsettled_balance && @should_send_notifications
      send_emails(uphold_connection)
    end
  end

  private

  def send_emails(uphold_connection)
    if !uphold_connection.uphold_verified? || uphold_connection.status.blank?
      Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are disconnected from Uphold.")
      PublisherMailer.wallet_not_connected(@publisher).deliver_later
    end

    # eyeshade omits the wallet address if the status is not ok
    # means that the transaction limits have been exceeded
    if uphold_connection.is_member? && uphold_connection.status != "ok"
      Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are restricted on Uphold.")
      PublisherMailer.uphold_member_restricted(@publisher).deliver_later
    end

    # The wallet's uphold account status has to exist because otherwise their wallet is just not connected
    if uphold_connection.uphold_verified? && uphold_connection.status.present? && !uphold_connection.is_member?
      Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are not a verified member on Uphold")
      PublisherMailer.uphold_kyc_incomplete(@publisher).deliver_later
    end
  end

  def should_only_notify?
    @payout_report.nil?
  end
end
