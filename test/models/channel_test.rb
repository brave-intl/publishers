# typed: false

require "test_helper"

class ChannelTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include Oauth2::Responses
  include MockUpholdResponses
  include MockRewardsResponses

  let(:state) { "some value" }
  let(:cookie) { state }

  before do
    # Mock out the creation of cards
    stub_request(:get, /cards/).to_return(body: [id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"].to_json)
    stub_request(:post, /cards/).to_return(body: {id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"}.to_json)
    stub_request(:get, /address/).to_return(body: [{formats: [{format: "uuid", value: "e306ec64-461b-4723-bf75-015ffc99ebe1"}], type: "anonymous"}].to_json)
    mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
    stub_rewards_parameters
    stub_get_user_deposits_capability
    stub_list_cards(currency: "BAT")
    stub_get_card(currency: "BAT")
    stub_create_card(http_status: "200", currency: "BAT")
    stub_get_user
  end

  test "deletes associated connections for channel on destroy" do
    uphold_channel = channels(:verified)
    gemini_channel = channels(:top_referrer_gemini_channel)

    ucfc = uphold_channel.uphold_connection
    assert ucfc
    gcfc = gemini_channel.gemini_connection
    assert gcfc

    uphold_channel.destroy!
    gemini_channel.destroy!

    assert_raises { gcfc.reload }
    assert_raises { ucfc.reload }
  end

  test "only pulls uphold connection for channel that matches the publisher's current uphold connection" do
    channel = channels(:verified)
    publisher = channel.publisher
    assert_equal channel.uphold_connection_for_channel.length, 1
    assert_equal channel.uphold_connection.uphold_connection_id, channel.publisher.uphold_connection.id

    publisher.uphold_connection.destroy
    channel.reload
    refute channel.uphold_connection

    scope = Oauth2::Config::Uphold.scope
    access_token_response = AccessTokenResponse.new(
      access_token: "derp",
      refresh_token: "derp",
      expires_in: 36000,
      token_type: "bearer",
      scope: scope
    )
    UpholdConnection.create_new_connection!(publisher, access_token_response)
    new_conn = publisher.reload.uphold_connection
    channel.reload
    job = CreateUpholdChannelCardJob.new
    job.perform(new_conn.id, channel.id)

    assert_equal publisher.channels.first.uphold_connection_for_channel.length, 1
    assert_equal publisher.channels.first.uphold_connection.uphold_connection_id, publisher.uphold_connection.id
  end

  test "site channel must have details" do
    channel = channels(:verified)
    assert channel.valid?

    assert_equal "verified.org", channel.details.brave_publisher_id
  end

  test "youtube channel must have details" do
    channel = channels(:google_verified)
    assert channel.valid?

    assert_equal "Some Other Guy's Channel", channel.details.title
  end

  test "channel can not change details" do
    channel = channels(:google_verified)
    assert channel.valid?

    channel.details = site_channel_details(:uphold_connected_details)
    refute channel.valid?

    assert_equal "can't be changed", channel.errors.messages[:details][0]
  end

  test "public_identifier is added on create and must be unique" do
    details = SiteChannelDetails.new
    channel = Channel.create(publisher: publishers(:completed), details: details)
    existing_channel = channels(:google_verified)

    channel.public_identifier = existing_channel.public_identifier
    assert_raises do
      channel.save!
    end
  end

  describe "validations for public_name uniqueness" do
    test "should validate uniqueness of public_name" do
      channel = channels(:google_verified)
      channel.public_name = "test_value"
      channel.save!

      channel_2 = channels(:new_site)
      channel_2.public_name = channel.public_name
      refute channel_2.valid?

      assert_equal "has already been taken", channel_2.errors.messages[:public_name][0]
    end

    test "should validate uniqueness and presence of public_identifier" do
      details = SiteChannelDetails.new
      channel = Channel.create(publisher: publishers(:completed), details: details)
      existing_channel = channels(:google_verified)

      channel.public_identifier = existing_channel.public_identifier
      assert_not channel.valid?
      assert_includes channel.errors[:public_identifier], "has already been taken"

      existing_channel.public_identifier = nil
      assert_not existing_channel.valid?
      assert_includes existing_channel.errors[:public_identifier], "can't be blank"
    end

    test "should validate public_name uniqueness across both public_name and public_identifier" do
      channel = channels(:google_verified)
      conflicting_channel = Channel.new(public_name: channel.public_identifier)
      assert_not conflicting_channel.valid?
      assert_includes conflicting_channel.errors[:public_name], "must be unique across both public_name and public_identifier"
    end

    test "should strip whitespace from public_name before validation" do
      channel = Channel.new(public_name: "example_name", public_identifier: "example_id")
      channel.public_name = " example name "
      channel.valid?
      assert_equal "examplename", channel.public_name
    end

    test "should save old public_name to ReservedPublicName after update" do
      channel = channels(:google_verified)
      channel.public_name = "old_name"
      channel.save!

      channel.public_name_changed_at = 3.months.ago
      channel.save!
      old_name = channel.public_name
      new_name = "new_new_name"
      channel.update(public_name: new_name)

      reserved = ReservedPublicName.find_by(public_name: old_name)
      assert_not_nil reserved
      assert_equal old_name, reserved.public_name
    end

    test "should validate public_name format and reserved name status" do
      channel = channels(:google_verified)
      invalid_name = "invalid name!"
      channel.public_name = invalid_name
      assert_not channel.valid?
      assert_includes channel.errors[:public_name], "must only contain letters, numbers, dashes, and underscores"

      too_short_name = "a"
      channel.public_name = too_short_name
      assert_not channel.valid?
      assert_includes channel.errors[:public_name], "must be between 3 and 32 characters in length"

      too_long_name = "a" * 33
      channel.public_name = too_long_name
      assert_not channel.valid?
      assert_includes channel.errors[:public_name], "must be between 3 and 32 characters in length"

      # Reserved name logic
      reserved_name = ReservedPublicName.create(public_name: "reserved", created_at: 6.months.ago, permanent: true)
      channel.public_name = reserved_name.public_name
      assert_not channel.valid?
      assert_includes channel.errors[:public_name], "already under use"
    end

    test "should validate public_name cannot be changed for two months after previous change" do
      channel = channels(:google_verified)
      channel.public_name = "old_name"
      channel.save!
      assert_raises do
        channel.update!(public_name: "new_name")
      end
    end

    test "should validate public_name_changed_at is set after a public_name change" do
      channel = channels(:google_verified)
      channel.public_name = "old_name"
      assert_nil channel.public_name_changed_at
      channel.save!

      assert_instance_of ActiveSupport::TimeWithZone, channel.public_name_changed_at
    end
  end

  test "publication_title is the site domain for site publishers" do
    channel = channels(:verified)
    assert_equal "verified.org", channel.details.brave_publisher_id
    assert_equal "verified.org", channel.details.publication_title
    assert_equal "verified.org", channel.publication_title
  end

  test "publication_title is the youtube channel title for youtube creators" do
    channel = channels(:youtube_new)
    assert_equal "The DIY Channel", channel.details.title
    assert_equal "The DIY Channel", channel.details.publication_title
    assert_equal "The DIY Channel", channel.publication_title
  end

  test "can get all visible site channels" do
    assert_equal 4, publishers(:global_media_group).channels.visible_site_channels.length
  end

  test "can get all visible youtube channels" do
    assert_equal 2, publishers(:global_media_group).channels.visible_youtube_channels.length
  end

  test "can get all visible channels" do
    assert_equal 6, publishers(:global_media_group).channels.visible.length
  end

  test "can get all verified channels" do
    assert_equal 3, publishers(:global_media_group).channels.verified.length
  end

  test "search returns right results" do
    channel = channels(:verified)

    assert Channel.search("verified.org").map(&:id).include? channel.id

    channel = channels(:twitch_verified)
    assert Channel.search("twtwtw2").map(&:id).include? channel.id

    channel = channels(:twitch_verified)
    assert Channel.search("twtwtw2").map(&:id).include? channel.id

    channel = channels(:global_yt1)
    assert Channel.search("global%").map(&:id).include? channel.id
  end

  test "verification_failed! updates verification status" do
    channel = channels(:default)

    refute channel.verified?
    assert_nil channel.verified_at
    refute channel.verification_failed?

    channel.verification_failed!("no_https")

    refute channel.verified?
    assert_nil channel.verified_at
    assert channel.verification_failed?
    assert_equal "no_https", channel.verification_details
  end

  test "verification_failed! updates verification status even with validation errors" do
    channel = channels(:fake1)

    refute channel.verified?
    assert_nil channel.verified_at
    refute channel.verification_failed?

    channel.verification_failed!("token_not_found_dns")

    refute channel.verified?
    assert_nil channel.verified_at
    assert channel.verification_failed?
    assert_equal "token_not_found_dns", channel.verification_details
  end

  test "verification_succeeded! updates verification status" do
    channel = channels(:default)

    refute channel.verified?
    refute channel.verified_at
    refute channel.verification_failed?

    channel.verification_succeeded!(false)

    assert channel.verified?
    assert_not_nil channel.verified_at
    refute channel.verification_failed?
  end

  test "verification_succeeded! for restricted channels fails" do
    channel = channels(:to_verify_restricted)

    channel.verification_succeeded!(false)

    channel.reload
    assert channel.errors[:base].include?("requires manual admin approval")
    refute channel.verified?
    assert_nil channel.verified_at
    refute channel.verification_failed?
  end

  test "verification_succeeded! for restricted channels with admin approval succeeds" do
    channel = channels(:to_verify_restricted)

    channel.verification_succeeded!(true)

    channel.reload
    assert channel.verified?
    assert_not_nil channel.verified_at
    refute channel.verification_failed?
  end

  test "verification_awaits_admin_approval! works" do
    channel = channels(:to_verify_restricted)

    channel.verification_awaiting_admin_approval!

    channel.reload
    refute channel.verified?
    assert_nil channel.verified_at
    refute channel.verification_failed?
    assert channel.verification_awaiting_admin_approval?
  end

  test "reverse verification" do
    channel = channels(:default)

    channel.verification_succeeded!(false)

    assert channel.verified?
    assert_not_nil channel.verified_at

    channel.update(verified: false)
    assert_nil channel.verified_at
  end

  test "verification_succeeded!() sets approved_by_admin flag" do
    channel = channels(:default)

    channel.verification_succeeded!(true)
    assert channel.verification_status = "approved_by_admin"
  end

  test "can remove a channel that is not contested" do
    channel = channels(:default)
    assert channel.destroy
  end

  test "can not destroy a contested_by channel" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)

    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform
    assert_raises do
      contested_by_channel.destroy
    end
  end

  test "if channel is a duplicate of a verified channel it must be contested sites" do
    channel = channels(:verified)
    contested_by_channel = Channel.new(publisher: publishers(:small_media_group))
    contested_by_channel.details = SiteChannelDetails.new(brave_publisher_id: "verified.org")

    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    assert channel.valid?
    assert contested_by_channel.valid?
  end

  test "if the same channel is trying to be registered twice" do
    channel = channels(:twitch_verified)

    new_channel = Channel.new(publisher: publishers(:twitch_verified), verified: true)
    new_channel.details = TwitchChannelDetails.new(
      twitch_channel_id: channel.details.twitch_channel_id,
      name: channel.details.name,
      display_name: channel.details.display_name
    )

    refute new_channel.valid?
    assert_equal "already exists on your account", new_channel.errors.messages[:base][0]
  end

  test "if channel is a duplicate of a verified channel it must be contested youtube" do
    channel = channels(:youtube_new)
    contested_by_channel = Channel.new(publisher: publishers(:small_media_group))
    contested_by_channel.details = YoutubeChannelDetails.new(youtube_channel_id: "323541525412313421",
      auth_user_id: "youtube_new_details_abc123",
      auth_provider: "google_oauth2",
      title: "The DIY Channel",
      thumbnail_url: "https://some_image_host.com/some_image.png")

    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    assert channel.valid?
    assert contested_by_channel.valid?
  end

  test "if channel is a duplicate of a verified channel it must be contested twitch" do
    channel = channels(:twitch_verified)
    contested_by_channel = Channel.new(publisher: publishers(:small_media_group))
    contested_by_channel.details = TwitchChannelDetails.new(twitch_channel_id: "78032",
      auth_user_id: "abc123",
      auth_provider: "twitch",
      name: channel.details.name,
      display_name: "TwTwTw",
      thumbnail_url: "https://some_image_host.com/some_image.png")

    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    assert channel.valid?
    assert contested_by_channel.valid?
  end

  test "publisher can't add a site channel if they already have an verified instance" do
    channel = channels(:verified)
    duplicate_channel = Channel.new(publisher: channel.publisher)
    duplicate_channel.details = SiteChannelDetails.new(brave_publisher_id: channel.details.brave_publisher_id)
    refute duplicate_channel.valid?
  end

  test "publisher can't add a site channel if they already have an unverified instance" do
    channel = channels(:default)
    duplicate_channel = Channel.new(publisher: channel.publisher)
    duplicate_channel.details = SiteChannelDetails.new(brave_publisher_id: channel.details.brave_publisher_id,
      verification_method: "dns")
    refute duplicate_channel.valid?
  end

  test "channel can't have a public name set to an existing public identifier" do
    channel = channels(:default)
    malicious_channel = channels(:verified)
    malicious_channel.public_name = channel.public_identifier

    refute malicious_channel.valid?
  end

  test "find_by_channel_identifier finds youtube channels" do
    channel = channels(:google_verified)
    found_channel = Channel.find_by_channel_identifier(channel.details.channel_identifier)
    assert_equal channel, found_channel
  end

  test "find_by_channel_identifier finds twitch channels" do
    channel = channels(:twitch_verified)
    found_channel = Channel.find_by_channel_identifier(channel.details.channel_identifier)
    assert_equal channel, found_channel
  end

  test "find_by_channel_identifier finds twitter channels" do
    channel = channels(:twitter_new)
    found_channel = Channel.find_by_channel_identifier(channel.details.channel_identifier)
    assert_equal channel, found_channel
  end

  test "find_by_channel_identifier finds site channels" do
    channel = channels(:verified)
    found_channel = Channel.find_by_channel_identifier(channel.details.channel_identifier)
    assert_equal channel, found_channel
  end

  test "find_by_channel_identifier finds vimeo channels" do
    channel = channels(:vimeo_new)
    found_channel = Channel.find_by_channel_identifier(channel.details.channel_identifier)
    assert_equal channel, found_channel
  end

  describe "#advanced_sort" do
    describe "youtube view count" do
      it "sorts by ascending" do
        channels = Channel.advanced_sort(Channel::YOUTUBE_VIEW_COUNT, "asc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["view_count"].nil?
          assert channel.details.stats["view_count"] > channels[index - 1].details.stats["view_count"]
        end
      end

      it "sorts by descending" do
        channels = Channel.advanced_sort(Channel::YOUTUBE_VIEW_COUNT, "desc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["view_count"].nil?
          assert channel.details.stats["view_count"] < channels[index - 1].details.stats["view_count"]
        end
      end
    end

    describe "twitch view count" do
      it "sorts by ascending" do
        channels = Channel.advanced_sort(Channel::TWITCH_VIEW_COUNT, "asc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["view_count"].nil?
          assert channel.details.stats["view_count"] >= channels[index - 1].details.stats["view_count"]
        end
      end

      it "sorts by descending" do
        channels = Channel.advanced_sort(Channel::TWITCH_VIEW_COUNT, "desc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["view_count"].nil?
          assert channel.details.stats["view_count"] <= channels[index - 1].details.stats["view_count"]
        end
      end
    end

    describe "follower count" do
      it "sorts by ascending" do
        channels = Channel.advanced_sort(Channel::FOLLOWER_COUNT, "asc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["followers_count"].nil?
          assert channel.details.stats["followers_count"] >= channels[index - 1].details.stats["followers_count"]
        end
      end

      it "sorts by descending" do
        channels = Channel.advanced_sort(Channel::FOLLOWER_COUNT, "desc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["followers_count"].nil?
          assert channel.details.stats["followers_count"] <= channels[index - 1].details.stats["followers_count"]
        end
      end
    end

    describe "video count" do
      it "sorts by ascending" do
        channels = Channel.advanced_sort(Channel::VIDEO_COUNT, "asc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["video_count"].nil?
          assert channel.details.stats["video_count"] > channels[index - 1].details.stats["video_count"]
        end
      end

      it "sorts by descending" do
        channels = Channel.advanced_sort(Channel::VIDEO_COUNT, "desc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["video_count"].nil?
          assert channel.details.stats["video_count"] < channels[index - 1].details.stats["video_count"]
        end
      end
    end

    describe "subscriber count" do
      it "sorts by ascending" do
        channels = Channel.advanced_sort(Channel::SUBSCRIBER_COUNT, "asc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["subscriber_count"].nil?
          assert channel.details.stats["subscriber_count"] > channels[index - 1].details.stats["subscriber_count"]
        end
      end

      it "sorts by descending" do
        channels = Channel.advanced_sort(Channel::SUBSCRIBER_COUNT, "desc")
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["subscriber_count"].nil?
          assert channel.details.stats["subscriber_count"] < channels[index - 1].details.stats["subscriber_count"]
        end
      end
    end

    describe "scopes" do
      let(:publisher) { publishers(:bitflyer_pub) }
      let(:channel) { publisher.channels.first }
      let(:connection) { publisher.bitflyer_connection }

      describe "#using_active_bitflyer_connection" do
        before do
          # I don't know why we create 79 channels on the fixture
          assert Channel.count == 80
        end

        test "count should eq 5" do
          assert_equal(5, Channel.using_active_bitflyer_connection.count)
        end

        describe "when oauth2 failure" do
          before do
            BitflyerConnection.update_all(oauth_refresh_failed: true, oauth_failure_email_sent: true)
          end

          test "it should return none" do
            assert Channel.using_active_bitflyer_connection.count == 0
          end
        end
      end

      describe "#missing_deposit_id" do
        before do
          assert Channel.count == 80
        end

        test "count should eq 73" do
          assert Channel.missing_deposit_id.count == 75
        end
      end
    end
  end
end
