require 'test_helper'

class LaunchPromoTest < ActiveJob::TestCase
  # Note: Changes in db persist during tests

  test "incorrect active_promo_id does not launch the promo" do
    # TO DO

    # ?.any_instance.stubs(:active_promo_id).returns("invalid-promo-id")

    # We can't stub this method, maybe we should consider moving rake task logic
    # into a service/lib/job and call it from within the task

    # assert_difference("Publisher.where.not(promo_token_2018q1: nil).count", 0) do
    #   assert_difference("ActionMailer::Base.deliveries.count" , 0) do
    #     Rake::Task["promo:launch_promo"].invoke
    #   end
    # end
  end

  test "generates a promo token for each publisher" do
    assert_difference("Publisher.where.not(promo_token_2018q1: nil).count", Publisher.count) do
      assert_difference("ActionMailer::Base.deliveries.count" , Publisher.count) do
        Rake::Task["promo:launch_promo"].invoke
      end
    end
  end
end


