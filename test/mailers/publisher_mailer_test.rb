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

  test "confirm_email_change" do
    publisher = publishers(:verified)
    publisher.pending_email = "alice-pending@verified.com"
    publisher.save

    email = PublisherMailer.confirm_email_change(publisher)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.pending_email], email.to
  end

  test "verify_email raises error if there is no send address" do
    publisher = publishers(:default)
    publisher.pending_email = ""
    publisher.email = ""
    publisher.save

    # verify error raised if no pending email
    assert_raises do
      PublisherMailer.verify_email(publisher).deliver_now
    end

    publisher.pending_email = "alice@default.org"
    publisher.email = "alice@default.org"
    publisher.save
    
    # verify nothing raised if pending email exists
    assert_nothing_raised do
      PublisherMailer.verify_email(publisher).deliver_now
    end
  end

  test "unverified_domain_reached_threshold" do
    domain = "default.org"
    email_address = "alice@default.org"
    email = PublisherMailer.unverified_domain_reached_threshold(domain, email_address)
    
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [email_address], email.to

    # verify the domain is in the subject
    assert_match "#{domain}", email.subject
  end

  test "unverified_domain_reached_threshold_internal" do
    domain = "default.org"
    email_address = "alice@default.org"
    email = PublisherMailer.unverified_domain_reached_threshold_internal(domain, email_address)
    
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal ['brave-publishers@localhost.local'], email.from

    # verify the domain is in the subject
    assert_match "#{domain}", email.subject

    # verify email is marked as internal
    assert_match "<Internal>", email.subject
  end
end
