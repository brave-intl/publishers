class JsonBuilders::PayoutReportJsonBuilder
  def initialize(payout_report:)
    @payout_report = payout_report
  end

  def build
    contents = []
    @payout_report.potential_payments.to_be_paid.find_each do |potential_payment|
      if potential_payment.kind == PotentialPayment::REFERRAL
        contents.push({
          "name" => "#{potential_payment.name}",
          "altcurrency" => "BAT",
          "probi" => "#{potential_payment.amount}",
          "fees" => "#{potential_payment.fees}",
          "authority" => "",
          "transactionId" => "#{potential_payment.payout_report_id}",
          "owner" => "#{Publisher.find(potential_payment.publisher_id).owner_identifier}",
          "type" => PotentialPayment::REFERRAL,
          "address" => "#{potential_payment.address}",
          "upholdId" => "#{potential_payment.uphold_id}",
          "walletProvider" => "#{potential_payment.wallet_provider}",
        })
      else
        channel = Channel.find_by(id: potential_payment.channel_id)
        if channel.present?
          contents.push({
            "publisher" => "#{channel.details.channel_identifier}",
            "name" => "#{potential_payment.name}",
            "altcurrency" => "BAT",
            "probi" => "#{potential_payment.amount}",
            "fees" => "#{potential_payment.fees}",
            "authority" => "",
            "transactionId" => "#{potential_payment.payout_report_id}",
            "owner" => "#{Publisher.find(potential_payment.publisher_id).owner_identifier}",
            "type" => PotentialPayment::CONTRIBUTION,
            "URL" => "#{Channel.find(potential_payment.channel_id).details.url}",
            "address" => "#{potential_payment.address}",
            "upholdId" => "#{potential_payment.uphold_id}",
            "walletProvider" => "#{potential_payment.wallet_provider}",
          })
        end
      end
    end
    contents
  end
end
