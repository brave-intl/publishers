class GeneratePayoutReportJob < ApplicationJob
  queue_as :low

  def perform(should_send_notifications: true, final: true)
    Rails.logger.info("Generating payout report..")

    payout_report = PayoutReport.create(final: final, fee_rate: fee_rate)
    publishers = Publisher.has_verified_channel

    payouts = []
    total_amount_probi = 0
    total_fees_probi = 0
    num_payments = 0

    publishers.find_each do |publisher|
      publisher_has_unsettled_balance = false
      wallet = publisher.wallet

      publisher.channels.verified.each do |channel|
        probi = wallet.channel_balances[channel.details.channel_identifier].probi
        next if probi <= 0

        publisher_has_unsettled_balance = true

        next if !publisher.uphold_verified? || wallet.address.blank?

        num_payments += 1
        total_amount_probi += probi
        fees_probi = calculate_fees(probi)
        total_fees_probi += fees_probi

        payouts.push({
          "publisher" => "#{channel.details.channel_identifier}",
          "altcurrency" => "BAT",
          "probi" => probi,
          "fees" => fees_probi,
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
        if !publisher.uphold_verified?
          PublisherMailer.verified_no_wallet(publisher).deliver_later
          
          # TO DO tell the publisher how much BAT they are missing out on
        elsif wallet.address.blank?
          PublisherMailer.verified_invalid_wallet(publisher).deliver_later
          # TO DO tell the publisher how much BAT they are missing out on
        end
      end
    end

    total_amount_bat = total_amount_probi / 1E18
    total_fees_bat = total_fees_probi / 1E18

    payout_report.update!(amount: total_amount_bat,
                          num_payments: num_payments,
                          contents: payouts.to_json,
                          fees: total_fees_bat)

    Rails.logger.info("Generated payout report #{payout_report.id}. #{num_payments} channels will be paid #{total_amount_bat} BAT.")
    payout_report
  end

  private

  def calculate_fees(probi)
    probi.to_d * fee_rate
  end

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate]
  end
end