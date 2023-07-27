# typed: ignore

# Creates a payout report and enqueues publishers to be included
class EnqueuePublishersForPayoutJob < ApplicationJob
  queue_as :scheduler

  def perform(final: true, manual: false, payout_report_id: "", publisher_ids: [], args: [])
    payout_report = if payout_report_id.present?
      PayoutReport.find(payout_report_id)
    else
      PayoutReport.create(final: final,
        manual: manual,
        fee_rate: fee_rate,
        expected_num_payments: 0)
    end

    raise ActiveRecord::RecordNotFound unless payout_report.present?

    ::EnqueuePublishersForPayoutService.new.call(payout_report, final: final, manual: manual, publisher_ids: publisher_ids, args: args)
  end

  private

  def fee_rate
    raise if Rails.configuration.pub_secrets[:fee_rate].blank?
    Rails.configuration.pub_secrets[:fee_rate].to_d
  end
end
