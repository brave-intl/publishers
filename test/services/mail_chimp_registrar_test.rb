require "test_helper"
require "webmock/minitest"
require 'vcr'

class MailChimpRegistrarTest < ActiveJob::TestCase
  def md5_hashed_email_address(email)
    md5 = Digest::MD5.new
    md5 << email.downcase
    md5
  end

  test "registers a new member and assigns all publishers interests" do
    prev_mailchimp_api_offline = Rails.application.secrets[:mailchimp_api_offline]
    Rails.application.secrets[:mailchimp_api_offline] = false

    begin
      publisher = publishers(:completed)

      email_md5 = md5_hashed_email_address(publisher.email)

      VCR.use_cassette("register_new_publisher_completed", :match_requests_on => [:method, :uri, :body]) do
        result = MailChimpRegistrar.new(publisher: publisher).perform

        assert_equal publisher.email, result.body[:email_address]
        # Brave payments
        assert result.body[:interests][:"d20f89f89a"]
        assert result.body[:interests][:"0e482e836d"]
        # Marketing
        assert result.body[:interests][:"477ca79775"]
        assert result.body[:interests][:"1d6c7e03b8"]
        # Advertisers
        refute result.body[:interests][:"42728538c3"]
        refute result.body[:interests][:"843e4b354b"]
      end
    ensure
      Rails.application.secrets[:mailchimp_api_offline] = prev_mailchimp_api_offline
    end
  end

  test "updates a registered member and does not modify publishers interests" do
    prev_mailchimp_api_offline = Rails.application.secrets[:mailchimp_api_offline]
    Rails.application.secrets[:mailchimp_api_offline] = false

    begin
      publisher = publishers(:completed)

      email_md5 = md5_hashed_email_address(publisher.email)

      VCR.use_cassette("update_publisher_completed", :match_requests_on => [:method, :uri, :body]) do
        result = MailChimpRegistrar.new(publisher: publisher).perform
        # Brave payments
        assert result.body[:interests][:"d20f89f89a"]
        refute result.body[:interests][:"0e482e836d"]
        # Marketing
        assert result.body[:interests][:"477ca79775"]
        refute result.body[:interests][:"1d6c7e03b8"]
        # Advertisers
        assert result.body[:interests][:"42728538c3"]
        refute result.body[:interests][:"843e4b354b"]
      end
    ensure
      Rails.application.secrets[:mailchimp_api_offline] = prev_mailchimp_api_offline
    end
  end

  test "initializes interests from a prior member and clears interests on prior member" do
    prev_mailchimp_api_offline = Rails.application.secrets[:mailchimp_api_offline]
    Rails.application.secrets[:mailchimp_api_offline] = false

    begin
      publisher = publishers(:verified)
      publisher.email = "alice.changed@verified.org"
      publisher.save

      email_md5 = md5_hashed_email_address(publisher.email)

      VCR.use_cassette("change_email_publisher_verified", :match_requests_on => [:method, :uri, :body]) do
        result = MailChimpRegistrar.new(publisher: publisher, prior_email: "alice@verified.org").perform

        assert result.body[:interests][:"d20f89f89a"]
        refute result.body[:interests][:"0e482e836d"]

        # Check that Advertiser interests were not copied over
        refute result.body[:interests][:"42728538c3"]
        refute result.body[:interests][:"843e4b354b"]

        prior_member_result = MailChimp::Api.get_member(email: "alice@verified.org")
        refute prior_member_result.body[:interests][:"d20f89f89a"]

        # Check that Advertiser interests were not cleared
        assert prior_member_result.body[:interests][:"42728538c3"]
        refute prior_member_result.body[:interests][:"843e4b354b"]
      end
    ensure
      Rails.application.secrets[:mailchimp_api_offline] = prev_mailchimp_api_offline
    end
  end
end