require 'test_helper'

class LaunchPromoTest < ActiveJob::TestCase

  before do
    require 'rake'
    Rake::Task.define_task :environment
    Rails.application.load_tasks
  end

  # test "incorrect active_promo_id does not launch the promo" do
  #   # TO DO

  #   # ?.any_instance.stubs(:active_promo_id).returns("invalid-promo-id")

  #   # We can't stub this method, maybe we should consider moving rake task logic
  #   # into a service/lib/job and call it from within the task

  #   # assert_difference("Publisher.where.not(promo_token_2018q1: nil).count", 0) do
  #   #   assert_difference("ActionMailer::Base.deliveries.count" , 0) do
  #   #     Rake::Task["promo:launch_promo"].invoke
  #   #   end
  #   # end
  # end

  test "generates a promo token and sends email to each publisher" do
    assert_difference("Publisher.where.not(promo_token_2018q1: nil).count", Publisher.count) do
      assert_enqueued_jobs(Publisher.count) do
        Rake::Task["promo:launch_promo"].invoke
        Rake::Task["promo:launch_promo"].reenable
      end
    end
  end

  test "only sends one email to each publisher if run twice (idempotence)" do
    publisher_one = publishers(:completed).dup
    publisher_two = publishers(:verified).dup

    Publisher.delete_all

    publisher_one.save!
    assert_equal Publisher.count, 1 # sanity check

    # run task once and store publisher_one's promo token
    assert_difference("Publisher.where.not(promo_token_2018q1: nil).count", 1) do
      assert_enqueued_jobs(1) do
        Rake::Task["promo:launch_promo"].invoke
        Rake::Task["promo:launch_promo"].reenable
      end
    end
    publisher_one.reload
    promo_token_one = publisher_one.promo_token_2018q1

    # add a second publisher
    publisher_two.save!
    assert_equal Publisher.count, 2

    # run task again and verify it has no effect on publisher_one
    assert_difference("Publisher.where.not(promo_token_2018q1: nil).count", 1) do
      assert_enqueued_jobs(1) do
        Rake::Task["promo:launch_promo"].invoke
        Rake::Task["promo:launch_promo"].reenable
      end
    end

    # verify promo_token_one matches after rake task run twice 
    assert_equal promo_token_one, publisher_one.promo_token_2018q1
  end
end