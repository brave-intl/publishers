require "test_helper"
require "jobs/sidekiq_test_case"

class EnqueueTopReferrerPayoutJobTest < NoTransactDBBleanupTest
  self.use_transactional_tests = false

  test "it enqueues only top referrers to to call EnqueuePublishersForPayoutJob (strategy: :deletion)" do
    top_publisher_ids = Publisher.with_verified_channel.in_top_referrer_program.pluck(:id)
    services = [Payout::UpholdService, Payout::BitflyerService, Payout::GeminiService]
    services.each do |service|
      service.any_instance.expects(:perform).with do |args|
        assert args[:publisher].id.in?(top_publisher_ids)
      end.returns([])
    end

    Payout::EnqueueTopReferrerPayoutJob.new.perform
  end

  test "excludes top publishers from the normal PayoutReport (strategy: :deletion)" do
    top_publisher_ids = Publisher.with_verified_channel.in_top_referrer_program.pluck(:id)
    services = [Payout::UpholdService, Payout::BitflyerService, Payout::GeminiService]
    services.each do |service|
      service.any_instance.expects(:perform).at_least_once.with do |args|
        refute args[:publisher].id.in?(top_publisher_ids)
      end.returns([])
    end

    EnqueuePublishersForPayoutJob.new.perform
  end
end
