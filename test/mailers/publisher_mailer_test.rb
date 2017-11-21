require 'test_helper'

class PublisherMailerTest < ActionMailer::TestCase
  test "welcome" do
    publisher = publishers(:default)
    email = PublisherMailer.welcome(publisher)

    # # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to

    # check that the brave_publisher_id is rendered as a link
    assert_match "Website Domain:default.org ( http://default.org )", email.text_part.body.to_s
    assert_match "href=\"http://#{publisher.brave_publisher_id}\"", email.html_part.body.to_s
  end

  test "uphold_account_changed" do
    publisher = publishers(:default)
    email = PublisherMailer.uphold_account_changed(publisher)

    # # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to

    # check that the brave_publisher_id is rendered as a link
    assert_match "Website Domain:default.org ( http://default.org )", email.text_part.body.to_s
    assert_match "href=\"http://#{publisher.brave_publisher_id}\"", email.html_part.body.to_s
  end

  test "verified_no_wallet" do
    publisher = publishers(:verified)
    email = PublisherMailer.verified_no_wallet(publisher, nil)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to

    # check that the brave publisher root is rendered as a link
    assert_match "( http://www.example.com/ )", email.text_part.body.to_s
    assert_match "href=\"http://www.example.com/\"", email.html_part.body.to_s
  end
end
