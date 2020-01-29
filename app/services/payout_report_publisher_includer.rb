class PayoutReportPublisherIncluder < BaseService
  # 5 BAT
  PROBI_THRESHOLD = 5 * 1E18

  class WalletError < StandardError; end

  def initialize(payout_report:, publisher:, should_send_notifications:)
    @publisher = publisher
    @payout_report = payout_report
    @should_send_notifications = should_send_notifications
  end

  def perform
    return if skip_publisher?

    uphold_connection = @publisher.uphold_connection

    wallet = PublisherWalletGetter.new(publisher: @publisher, include_transactions: false).perform

    raise WalletError.new(message: "There was a problem fetching the wallet for #{@publisher.id}") if wallet.blank?

    uphold_connection.sync_from_uphold!
    if uphold_connection.missing_card?
      uphold_connection.create_uphold_cards
    end

    probi = wallet.referral_balance.amount_probi # probi = balance
    total_probi = probi

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
        wallet_provider_id: uphold_connection.uphold_id,
        wallet_provider: PotentialPayment.wallet_providers['uphold'],
        suspended: @publisher.suspended?,
        status: @publisher.last_status_update&.status
      )
    end

    # Create potential payments for channel contributions
    @publisher.channels.verified.each do |channel|
      probi = wallet.channel_balances[channel.details.channel_identifier].amount_probi # probi = balance - fee
      fee_probi = wallet.channel_balances[channel.details.channel_identifier].fees_probi # fee = balance - probi
      total_probi += probi

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
          wallet_provider_id: uphold_connection.uphold_id,
          wallet_provider: PotentialPayment.wallet_providers['uphold'],
          suspended: @publisher.suspended?,
          status: @publisher.last_status_update&.status,
          channel_stats: channel.details.stats,
          channel_type: channel.details_type
        )
      end
    end

    # Notify publishers that have money waiting, but will not will not receive funds
    if total_probi > PROBI_THRESHOLD && @should_send_notifications
      send_emails(uphold_connection, probi_to_bat(total_probi).round(1))
    end
  rescue StandardError => e
    PayoutMessage.create(payout_report: @payout_report, publisher: @publisher, message: e.message) unless should_only_notify?

    raise e
  end

  private

  # Verbose way of creating messages for the publisher.
  def skip_publisher?
    payout_message = PayoutMessage.new(payout_report: @payout_report, publisher: @publisher)

    if !@publisher.has_verified_channel?
      payout_message.update(message: "Publisher has no verified channels.") unless should_only_notify?
      return true
    end

    if @publisher.excluded_from_payout?
      payout_message.update(message: "Publisher has been marked as excluded from payout") unless should_only_notify?
      return true
    end

    if @publisher.hold?
      payout_message.update(message: "Publisher is currently in hold status") unless should_only_notify?
      return true
    end

    if @publisher.paypal_connection.present?
      payout_message.update(message: "Publisher currently has a Paypal Connection Present and therefore cannot be paid through Uphold.") unless should_only_notify?
      return true
    end

    if @publisher.uphold_connection&.japanese_account?
      payout_message.update(message: "Publisher's account is located in Japan and is not paid out in this report") unless should_only_notify?
      return true
    end

    false
  end

  def send_emails(uphold_connection, total_amount)
    if !uphold_connection.uphold_verified? || uphold_connection.status.blank?
      Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are disconnected from Uphold.")
      PublisherMailer.wallet_not_connected(@publisher, total_amount).deliver_later
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
      PublisherMailer.uphold_kyc_incomplete(@publisher, total_amount).deliver_later
    end
  end

  def should_only_notify?
    @payout_report.nil?
  end

  # Converts Probi to BAT, original implementation Eyeshade::BaseBalance
  def probi_to_bat(probi)
    probi.to_d / 1E18
  end
end
