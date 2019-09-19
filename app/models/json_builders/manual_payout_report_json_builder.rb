class JsonBuilders::ManualPayoutReportJsonBuilder
  def initialize(payout_report:)
    @payout_report = payout_report
  end

  def build
    contents = []
    @payout_report.potential_payments.to_be_paid.where(kind: PotentialPayment::MANUAL).find_each do |potential_payment|
      publisher = Publisher.find(potential_payment.publisher_id).owner_identifier

      contents.push(
        {
          name: potential_payment.name,
          altcurrency: "BAT",
          probi: potential_payment.amount.to_s,
          fees: potential_payment.fees.to_s,
          authority: Publisher.find(potential_payment.finalized_by_id).email,
          transactionId: potential_payment.payout_report_id,
          owner: publisher,
          publisher: publisher,
          type: PotentialPayment::MANUAL,
          address: potential_payment.address,
          upholdId: potential_payment.uphold_id,
          documentId: potential_payment.invoice_id,
        }
      )
    end
    contents
  end
end
