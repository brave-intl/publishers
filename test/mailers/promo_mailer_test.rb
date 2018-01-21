require 'test_helper'

class PromoMailerTest < ActionMailer::TestCase
  include PromosHelper

  test "activate_promo_2018q1" do
    publisher = publishers(:default)
    email = PromoMailer.activate_promo_2018q1(publisher)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to
  end
end
