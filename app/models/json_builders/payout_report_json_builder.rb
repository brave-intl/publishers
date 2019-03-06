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
          "upholdId" => "#{potential_payment.uphold_id}"
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
            "upholdId" => "#{potential_payment.uphold_id}"
          })
        end
      end
    end
    @payout_report.potential_payments.manual_to_be_paid.find_each do |potential_payment|
      contents.push({
          "name" => "#{potential_payment.name}",
          "altcurrency" => "BAT",
          "probi" => "#{potential_payment.amount}",
          "fees" => "#{potential_payment.fees}",
          "authority" => "#{potential_payment.finalized_by_id}",
          "transactionId" => "#{potential_payment.payout_report_id}",
          "owner" => "#{Publisher.find(potential_payment.publisher_id).owner_identifier}",
          "type" => PotentialPayment::MANUAL,
          "address" => "#{potential_payment.address}",
          "upholdId" => "#{potential_payment.uphold_id}",
          "documentId" => "#{potential_payment.invoice_id}"
        })
    end
    contents
  end
end
