class GeneratePayoutReportJob < ApplicationJob
  queue_as :low

  def perform(should_send_notifications: true, final: true)
    Rails.logger.info("Generating payout report..")

    payout_report = PayoutReport.create(final: final, fee_rate: fee_rate)
    publishers = Publisher.with_verified_channel

    payouts = []
    total_amount_probi = 0
    total_fee_probi = 0
    num_payments = 0

    publishers.find_each do |publisher|
      publisher_has_unsettled_balance = false
      wallet = publisher.wallet

      publisher.channels.verified.each do |channel|
        probi = wallet.channel_balances[channel_identifier(channel)].probi # probi = balance - fee
        next if probi <= 0

        publisher_has_unsettled_balance = true

        next if !publisher.uphold_verified? || wallet.address.blank?

        fee_probi = wallet.channel_balances[channel_identifier(channel)].fee # fee = balance - probi

        num_payments += 1
        total_amount_probi += probi
        total_fee_probi += fee_probi

        payouts.push({
          "publisher" => "#{channel_identifier(channel)}",
          "altcurrency" => "BAT",
          "probi" => probi,
          "fees" => fee_probi,
          "authority" => "GeneratePayoutReportJob",
          "transactionId" => "#{payout_report.id}",
          "owner" => "#{publisher.owner_identifier}",
          "type" => "contribution",
          "URL" => "#{channel.details.url}",
          "address" => "#{wallet.address}",
          "currency" => "publisher.default_currency"
        })
      end

      # Notify publishers that have money waiting, but will not will not receive funds
      if publisher_has_unsettled_balance && should_send_notifications
        if !publisher.uphold_verified? || wallet.address.blank?
          PublisherMailer.wallet_not_connected(publisher).deliver_later
        end
      end
    end

    payout_report.update!(amount: total_amount_probi,
                          num_payments: num_payments,
                          contents: payouts.to_json,
                          fees: total_fee_probi)

    Rails.logger.info("Generated payout report #{payout_report.id}. #{num_payments} channels will be paid #{total_amount_probi * 1E18} BAT.")
    payout_report
  end

  private

  # TODO: Remove this method and use channel.details.channel_identifier
  # instead when twitch#author is used everywhere
  def channel_identifier(channel)
    if channel.details_type == "TwitchChannelDetails" && !Rails.env.test?
      "twitch#author:#{channel.details.name}"
    else
      channel.details.channel_identifier
    end
  end

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end
