# frozen_string_literal: true

class IncludePublisherInPayoutReportJob
  include Sidekiq::Worker
  sidekiq_options queue: 'scheduler'

  GEMINI = :gemini
  PAYPAL = :paypal
  UPHOLD = :uphold
  BITFLYER = :bitflyer
  MANUAL = :manual

  def perform(arguments = {})
    arguments = arguments.symbolize_keys
    # If payout_report_id is not present, we only want to send notifications
    # not create payments
    payout_report_id = arguments[:payout_report_id]
    publisher_id = arguments[:publisher_id]

    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id)
    else
      payout_report = nil
    end

    potential_payment_job = nil
    publisher = Publisher.find(publisher_id)

    attrs_payment_job = {
      publisher: publisher,
      payout_report: payout_report,
    }

    case arguments[:kind].to_sym
    when GEMINI
      potential_payment_job = Payout::GeminiService
    when PAYPAL
      potential_payment_job = Payout::PaypalService
    when UPHOLD
      potential_payment_job = Payout::UpholdService
    when BITFLYER
      return Payout::BitflyerService.build.perform(attrs_payment_job)
    when MANUAL
      potential_payment_job = Payout::ManualPayoutReportPublisherIncluder
    end

    potential_payment_job.new(attrs_payment_job).perform
  end
end
