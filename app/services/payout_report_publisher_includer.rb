class PayoutReportPublisherIncluder < BaseService
  def initialize(payout_report:, publisher:, should_send_notifications:)
    @publisher = publisher
    @payout_report = payout_report
    @should_send_notifications = should_send_notifications
  end

  def perform
    return if !@publisher.has_verified_channel? || @publisher.locked? || @publisher.excluded_from_payout?
    publisher_has_unsettled_balance = false

    create_uphold_card_for_default_currency_if_needed

    publisher_has_unsettled_balance = false
    wallet = PublisherWalletGetter.new(publisher: @publisher).perform

    uphold_status = wallet.uphold_account_status
    uphold_member = wallet.is_a_member?
    reauthorization_needed = wallet.action == "re-authorize"
    suspended = @publisher.suspended?
    uphold_id = wallet.uphold_id

    probi = wallet.referral_balance.amount_probi # probi = balance
    publisher_has_unsettled_balance = probi.to_i.positive?

    unless should_only_notify?
      PotentialPayment.create(payout_report_id: @payout_report.id,
                              name: @publisher.name,
                              amount: "#{probi}",
                              fees: "0",
                              publisher_id: @publisher.id,
                              kind: PotentialPayment::REFERRAL,
                              address: "#{wallet.address}",
                              uphold_status: uphold_status,
                              reauthorization_needed: reauthorization_needed,
                              uphold_member: uphold_member,
                              suspended: suspended,
                              uphold_id: uphold_id)
    end

    # Create potential payments for channel contributions
    @publisher.channels.verified.each do |channel|
      probi = wallet.channel_balances[channel.details.channel_identifier].amount_probi # probi = balance - fee
      publisher_has_unsettled_balance = probi.positive? ? true : publisher_has_unsettled_balance

      fee_probi = wallet.channel_balances[channel.details.channel_identifier].fees_probi # fee = balance - probi

      unless should_only_notify?
        PotentialPayment.create(payout_report_id: @payout_report.id,
                                name: "#{channel.publication_title}",
                                amount: "#{probi}",
                                fees: "#{fee_probi}",
                                publisher_id: @publisher.id,
                                channel_id: channel.id,
                                kind: PotentialPayment::CONTRIBUTION,
                                address: "#{wallet.address}",
                                url: "#{channel.details.url}",
                                uphold_status: uphold_status,
                                reauthorization_needed: reauthorization_needed,
                                uphold_member: uphold_member,
                                suspended: suspended,
                                uphold_id: uphold_id)
      end
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

  private

  def create_uphold_card_for_default_currency_if_needed
    if @publisher.can_create_uphold_cards? &&
      @publisher.default_currency_confirmed_at.present? &&
      @publisher.wallet.address.blank?
      CreateUpholdCardsJob.perform_now(publisher_id: @publisher.id)
    end
  end

  def should_only_notify?
    @payout_report.nil?
  end
end
