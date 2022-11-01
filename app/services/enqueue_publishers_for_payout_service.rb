class EnqueuePublishersForPayoutService
  def call(payout_report,
           final: true,
           manual: false,
           publisher_ids: [],
           allowed_regions: Rewards::Parameters.new.fetch_allowed_regions,
           args: [])
    unless payout_report.is_a?(PayoutReport)
      # Wondering if sorbet can just do stuff like this?
      raise ArgumentError.new("Invalid argument type. Must be PayoutReport")
    end

    @payout_report = payout_report
    @manual = manual
    @final = final
    @publisher_ids = publisher_ids

    begin
      enqueue_payout(allowed_regions_passed: allowed_regions)
    rescue => error
      @payout_report.update!(status: "Error - #{error.message}")
    end

    @payout_report
  end

  private

  def enqueue_payout(allowed_regions_passed:)
    base_publishers = Publisher

    filtered_publishers = if @publisher_ids.present?
      base_publishers.where(id: @publisher_ids)
    else
      base_publishers.with_verified_channel.not_in_top_referrer_program
                          end


    # DEAL WITH MANUAL CASE AND SET UP EACH WALLETS VARS
    wallet_providers_to_insert = if @manual
      [{service: Payout::ManualPayoutReportPublisherIncluder.new, initial_publishers: filtered_publishers.invoice}]
    else
      [
        {
          service: Payout::UpholdService.new,
          initial_publishers: filtered_publishers
            .valid_payable_uphold_creators,
          allowed_regions: allowed_regions_passed[:uphold][:allow]
        },
        {
          service: Payout::GeminiService.new,
          initial_publishers: filtered_publishers
            .valid_payable_gemini_creators,
          allowed_regions: allowed_regions_passed[:gemini][:allow]

        },
        {
          service: Payout::BitflyerService.build,
          initial_publishers: filtered_publishers
            .valid_payable_bitflyer_creators,
        }
      ]
    end

    # Roll back if there's any problem. Use read_uncommitted to not lock any
    # tables for maximum performance
    ActiveRecord::Base.transaction(isolation: :read_uncommitted) do
      # LOOP FOR EACH TYPE OF CONNECTION
      wallet_providers_to_insert.each do |wallet_provider_info|
        service = wallet_provider_info[:service]
        publishers = wallet_provider_info[:initial_publishers]
        allowed_regions = wallet_provider_info[:allowed_regions]

        # Single query using select rather than 2 queries using pluck
        eager_loaded_publishers = Publisher.strict_loading.includes(
          :status_updates,
          :uphold_connection,
          :gemini_connection,
          :bitflyer_connection
        ).preload(
          channels: :details
        ).where(id: publishers.select(:id))

        generate_payments_and_save(
          publishers: eager_loaded_publishers,
          service: service,
          allowed_regions: allowed_regions
        )
      end
    end
  end

  def generate_payments_and_save(publishers:, service:, allowed_regions:)
    # EXPECTED NUMBER OF PAYMENTS
    number_of_payments = PayoutReport.expected_num_payments(publishers)

    @payout_report.with_lock do
      @payout_report.reload
      @payout_report.expected_num_payments = number_of_payments + @payout_report.expected_num_payments
      @payout_report.save!
    end

    # CALL POTENTIAL PAYMENT OBJECT CREATION
    @payout_report.update!(status: "Enqueued")

    publishers.find_in_batches(batch_size: 10000) do |group|
      potential_payments = []

      group.each do |publisher|
        potential_payments.concat(service.perform(publisher: publisher, payout_report: @payout_report, allowed_regions: allowed_regions))
      end

      # DB Insert
      PotentialPayment.import(potential_payments, validate: false)
    end

    @payout_report.update!(status: "Complete")
  end
end
