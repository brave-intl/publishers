class PayoutReportPublisherIncluder < BaseService
  def initialize(payout_report:, publisher:, should_send_notifications:)
    @publisher = publisher
    @payout_report = payout_report
    @should_send_notifications = should_send_notifications
  end

  def perform
    return if @publisher.suspended? || !@publisher.has_verified_channel? || @publisher.excluded_from_payout?
    publisher_has_unsettled_balance = false

    wallet = @publisher.wallet
    # If the wallet has been blocked from uphold's terms of service. In this state users are unable to login or access uphold.
    return if wallet.nil? || wallet.blocked?

    probi = wallet.referral_balance.amount_probi # probi = balance
    if probi.to_i.positive?
      publisher_has_unsettled_balance = true

      if create_payment?
        PotentialPayment.create(payout_report_id: @payout_report.id,
                                name: @publisher.name,
                                amount: "#{probi}",
                                fees: "0",
                                publisher_id: @publisher.id,
                                kind: PotentialPayment::REFERRAL,
                                address: "#{wallet.address}")
      end
    end

    @publisher.channels.verified.each do |channel|
      probi = wallet.channel_balances[channel.details.channel_identifier].amount_probi # probi = balance - fee
      next unless probi.to_i.positive? && create_payment?

      publisher_has_unsettled_balance = true
      fee_probi = wallet.channel_balances[channel.details.channel_identifier].fees_probi # fee = balance - probi
      PotentialPayment.create(payout_report_id: @payout_report.id,
                              name: "#{channel.publication_title}",
                              amount: "#{probi}",
                              fees: "#{fee_probi}",
                              publisher_id: @publisher.id,
                              channel_id: channel.id,
                              kind: PotentialPayment::CONTRIBUTION,
                              address: "#{wallet.address}",
                              url: "#{channel.details.url}")
    end

    # Notify publishers that have money waiting, but will not will not receive funds
    if publisher_has_unsettled_balance && @should_send_notifications
      if !@publisher.uphold_verified? || wallet.uphold_account_status.nil?
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are disconnected from Uphold.")
        PublisherMailer.wallet_not_connected(@publisher).deliver_later
      end

      # eyeshade omits the wallet address if the status is not ok
      # means that the transaction limits have been exceeded
      if wallet.is_a_member? && wallet.address.blank?
        PublisherMailer.uphold_member_restricted(@publisher).deliver_later
      end

      # The wallet's uphold account status has to exist because otherwise their wallet is just not connected
      if @publisher.uphold_verified? && wallet.uphold_account_status.present? && wallet.not_a_member?
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are not a verified member on Uphold")
        PublisherMailer.uphold_kyc_incomplete(@publisher).deliver_later
      end
    end
  end

  def create_payment?
    @publisher.uphold_verified? && @publisher.wallet.authorized? && @publisher.wallet.is_a_member? && !should_only_notify?
  end

  def should_only_notify?
    @payout_report.nil?
  end
end

