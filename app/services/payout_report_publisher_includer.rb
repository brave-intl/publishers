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
    return if wallet.nil?

    probi = wallet.channel_balances[@publisher.owner_identifier].probi_before_fees # probi = balance
    if probi.positive?
      publisher_has_unsettled_balance = true

      if @publisher.uphold_verified? && wallet.address.present?
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
      next unless probi.positive? && @publisher.uphold_verified? && wallet.address.present?

      publisher_has_unsettled_balance = true
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
      if !@publisher.uphold_verified? || wallet.address.blank?
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are disconnected from Uphold.")
        PublisherMailer.wallet_not_connected(@publisher).deliver_later
      end
    end
  end
end

