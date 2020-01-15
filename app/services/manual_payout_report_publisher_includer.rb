class ManualPayoutReportPublisherIncluder < BaseService
  def initialize(payout_report:, publisher:, should_send_notifications:)
    @publisher = publisher
    @payout_report = payout_report
    @should_send_notifications = should_send_notifications
  end

  def perform
    return if @publisher.suspended? || @publisher.no_grants? || @publisher.hold? || @publisher.locked? || @publisher.excluded_from_payout? || @publisher.paypal_connection.present?

    uphold_connection = @publisher.uphold_connection

    suspended = @publisher.suspended?

    invoices = Invoice.where(partner_id: @publisher.id, status: Invoice::IN_PROGRESS)
    invoices.each do |invoice|
      amount = invoice.finalized_amount_to_probi
      next if uphold_connection.japanese_account?
      PotentialPayment.create(payout_report_id: @payout_report.id,
                              name: @publisher.name,
                              amount: amount,
                              fees: "0",
                              publisher_id: @publisher.id,
                              kind: PotentialPayment::MANUAL,
                              address: uphold_connection.address.to_s,
                              uphold_status: uphold_connection.status,
                              reauthorization_needed: uphold_connection.uphold_access_parameters.blank?,
                              uphold_member: uphold_connection.is_member,
                              suspended: suspended,
                              uphold_id: uphold_connection.uphold_id,
                              invoice_id: invoice.id,
                              finalized_by_id: invoice.finalized_by_id)
    end
  end
end
