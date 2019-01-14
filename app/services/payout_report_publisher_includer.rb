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

    probi = wallet.channel_balances[@publisher.owner_identifier].probi_before_fees # probi = balance
    if probi.positive?
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
      probi = wallet.channel_balances[channel.details.channel_identifier].probi # probi = balance - fee
      publisher_has_unsettled_balance = probi.positive? ? true : publisher_has_unsettled_balance

      next unless probi.positive? && create_payment?

      fee_probi = wallet.channel_balances[channel.details.channel_identifier].fee # fee = balance - probi
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
      if !@publisher.uphold_verified? || wallet.status.nil?
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are disconnected from Uphold.")
        PublisherMailer.wallet_not_connected(@publisher).deliver_later
      end

      if @publisher.uphold_verified? && wallet.not_a_member?
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are not a verified member on Uphold")
        PublisherMailer.uphold_kyc_incomplete(@publisher).deliver_later
      end
    end
  end

  def create_payment?
    @publisher.uphold_verified? && @publisher.wallet.address.present? && @publisher.wallet.is_a_member? && !should_only_notify?
  end

  def should_only_notify?
    @payout_report.nil?
  end
end

