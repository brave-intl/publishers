require 'test_helper'

class LaunchPromo2018q1JobTest < ActiveJob::TestCase
  test "generates a promo token for each publisher" do
    assert_difference("Publisher.where.not(promo_token_2018q1: nil).count", Publisher.count) do
      LaunchPromo2018q1Job.new.perform
    end
  end

  test "generates tokens and sends email to all publishers" do
    assert_difference("ActionMailer::Base.deliveries.count" , Publisher.count) do
      LaunchPromo2018q1Job.new.perform
    end
  end
end