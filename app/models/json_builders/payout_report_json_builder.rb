class JsonBuilders::PayoutReportJsonBuilder
  def initialize(payout_report:)
    @payout_report = payout_report
  end

  def build
    contents = []
    @payout_report.potential_payments.each do |potential_payment|
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
          "address" => "#{potential_payment.address}"
        })
      else
        contents.push({
          "publisher" => "#{Channel.find(potential_payment.channel_id).details.channel_identifier}",
          "name" => "#{potential_payment.name}",
          "altcurrency" => "BAT",
          "probi" => "#{potential_payment.amount}",
          "fees" => "#{potential_payment.fees}",
          "authority" => "",
          "transactionId" => "#{potential_payment.payout_report_id}",
          "owner" => "#{Publisher.find(potential_payment.publisher_id).owner_identifier}",
          "type" => PotentialPayment::CONTRIBUTION,
          "address" => "#{potential_payment.address}"
        })
      end
    end
    
    contents
  end
end