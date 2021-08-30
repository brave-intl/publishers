# Creates a payout report and enqueues publishers to be included
class EnqueuePublishersForPayoutJob < ApplicationJob
  queue_as :scheduler

  def perform(final: true, manual: false, payout_report_id: "", args: [])
    Rails.logger.info("Enqueuing publishers for payment.")

    if payout_report_id.present?
      payout_report = PayoutReport.find(payout_report_id)
    else
      payout_report = PayoutReport.create(final: final,
                                          manual: manual,
                                          fee_rate: fee_rate,
                                          expected_num_payments: 0)
    end

    enqueue_payout(
      manual: manual,
      payout_report: payout_report
    )

    payout_report
  end

  private

  def enqueue_payout(payout_report:, manual:)
    filtered_publishers = Publisher.with_verified_channel.not_in_top_referrer_program

    # DEAL WITH MANUAL CASE AND SET UP EACH WALLETS VARS
    wallet_providers_to_insert = if manual
                                   [{ service: Payout::ManualPayoutReportPublisherIncluder.new, initial_publishers: filtered_publishers.invoice }]
                                 else
                                   [
                                     { service: Payout::UpholdService.new, initial_publishers: filtered_publishers.valid_payable_uphold_creators },
                                     { service: Payout::GeminiService.new, initial_publishers: filtered_publishers.valid_payable_gemini_creators },
                                     { service: Payout::BitflyerService.build, initial_publishers: filtered_publishers.valid_payable_bitflyer_creators },
                                   ]
                                 end

    # LOOP FOR EACH TYPE OF CONNECTION
    wallet_providers_to_insert.each do |wallet_provider_info|
      service = wallet_provider_info[:service]
      publishers = wallet_provider_info[:initial_publishers]

      # EXPECTED NUMBER OF PAYMENTS
      number_of_payments = PayoutReport.expected_num_payments(publishers)
      payout_report.with_lock do
        payout_report.reload
        payout_report.expected_num_payments = number_of_payments + payout_report.expected_num_payments
        payout_report.save!
      end

      # CALL POTENTIAL PAYMENT OBJECT CREATION
      publishers.find_in_batches(batch_size: 10000) do |group|
        potential_payments = []

        group.each do |publisher|
          potential_payments += service.perform(publisher: publisher, payout_report: payout_report)
        end

        # DB Insert
        PotentialPayment.import(potential_payments, validate: false)
      end
    end
  end

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end
