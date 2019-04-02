class JsonBuilders::ManualPayoutReportJsonBuilder
  def initialize(payout_report:)
    @payout_report = payout_report
  end

  def build
    contents = []
    @payout_report.potential_payments.to_be_paid.where(kind: PotentialPayment::MANUAL).find_each do |potential_payment|
      contents.push(
        {
          "name" => potential_payment.name.to_s,
          "altcurrency" => "BAT",
          "probi" => potential_payment.amount.to_s,
          "fees" => potential_payment.fees.to_s,
          "authority" => Publisher.find(potential_payment.finalized_by_id).email,
          "transactionId" => potential_payment.payout_report_id.to_s,
          "owner" => Publisher.find(potential_payment.publisher_id).owner_identifier.to_s,
          "type" => PotentialPayment::MANUAL,
          "address" => potential_payment.address.to_s,
          "upholdId" => potential_payment.uphold_id.to_s,
          "documentId" => potential_payment.invoice_id.to_s,
        }
      )
    end
    contents
  end
end
