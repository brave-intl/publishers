require "test_helper"
require "webmock/minitest"

class SiteChannelVerifierTest < ActiveSupport::TestCase
  def setup
    # Rails.application.secrets[:api_eyeshade_offline] = false
  end

  def teardown
    # Rails.application.secrets[:api_eyeshade_offline] = true
  end

  test "will verify against the domain's server .well-known file in offline mode if brave_publisher_id not blank" do
    begin
      stub_request(:get, "https://foo.com/.well-known/brave-payments-verification.txt").
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'foo.com', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: "ASDFG", headers: {})

      Rails.application.secrets[:api_eyeshade_offline] = true
      pub = publishers(:verified)
      c = Channel.new(publisher: pub)
      c.details = SiteChannelDetails.new(brave_publisher_id: "foo.com",
                                         verification_method: "wordpress")
      c.save
      c.details.verification_token = "ASDFG"
      c.details.save

      refute c.verified?
      verifier = SiteChannelVerifier.new(channel: c)
      verifier.perform
      c.reload
      assert c.verified?

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = true
    end
  end

  test "will fail to verify in offline mode if brave_publisher_id is blank" do
    begin
      stub_request(:get, "https://foo.com/.well-known/brave-payments-verification.txt").
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'foo.com', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: "ASDFG", headers: {})

      Rails.application.secrets[:api_eyeshade_offline] = true
      pub = publishers(:verified)
      c = Channel.new(publisher: pub)
      c.details = SiteChannelDetails.new(brave_publisher_id: "",
                                         verification_method: "wordpress")
      c.save
      c.details.verification_token = "ASDFG"
      c.details.save

      refute c.verified?
      verifier = SiteChannelVerifier.new(channel: c)
      verifier.perform
      c.reload
      refute c.verified?
      assert c.verification_failed?

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = true
    end
  end

  test "verifies using dns TXT entry in offline mode" do
    begin
      stub_request(:get, "https://foo.com/.well-known/brave-payments-verification.txt").
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'foo.com', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: "ASDFG", headers: {})

      Rails.application.secrets[:api_eyeshade_offline] = true
      pub = publishers(:verified)
      c = Channel.new(publisher: pub)
      c.details = SiteChannelDetails.new(brave_publisher_id: "foo.com",
                                         verification_method: "dns_record")
      c.save
      c.details.verification_token = "ASDFG"
      c.details.save

      refute c.verified?
      verifier = SiteChannelVerifier.new(channel: c)
      verifier.perform
      c.reload

      # ToDo: Mock the DNS call
      #
      # assert c.verified?

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = true
    end
  end

  # ToDo: Test online mode

end