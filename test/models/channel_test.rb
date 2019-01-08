require "test_helper"

class ChannelTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

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

  test "publication_title is the site domain for site publishers" do
    channel = channels(:verified)
    assert_equal 'verified.org', channel.details.brave_publisher_id
    assert_equal 'verified.org', channel.details.publication_title
    assert_equal 'verified.org', channel.publication_title
  end

  test "publication_title is the youtube channel title for youtube creators" do
    channel = channels(:youtube_new)
    assert_equal 'The DIY Channel', channel.details.title
    assert_equal 'The DIY Channel', channel.details.publication_title
    assert_equal 'The DIY Channel', channel.publication_title
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

  describe "#advanced_sort" do
    describe 'youtube view count' do
      it 'sorts by ascending' do
        channels = Channel.advanced_sort(Channel::YOUTUBE_VIEW_COUNT, 'asc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["view_count"].nil?
          assert channel.details.stats["view_count"] > channels[index-1].details.stats["view_count"]
        end
      end

      it 'sorts by descending' do
        channels = Channel.advanced_sort(Channel::YOUTUBE_VIEW_COUNT, 'desc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["view_count"].nil?
          assert channel.details.stats["view_count"] < channels[index-1].details.stats["view_count"]
        end
      end
    end

    describe 'twitch view count' do
      it 'sorts by ascending' do
        channels = Channel.advanced_sort(Channel::TWITCH_VIEW_COUNT, 'asc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["view_count"].nil?
          assert channel.details.stats["view_count"] > channels[index-1].details.stats["view_count"]
        end
      end

      it 'sorts by descending' do
        channels = Channel.advanced_sort(Channel::TWITCH_VIEW_COUNT, 'desc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["view_count"].nil?
          assert channel.details.stats["view_count"] < channels[index-1].details.stats["view_count"]
        end
      end
    end

    describe 'follower count' do
      it 'sorts by ascending' do
        channels = Channel.advanced_sort(Channel::FOLLOWER_COUNT, 'asc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["followers_count"].nil?
          assert channel.details.stats["followers_count"] > channels[index-1].details.stats["followers_count"]
        end
      end

      it 'sorts by descending' do
        channels = Channel.advanced_sort(Channel::FOLLOWER_COUNT, 'desc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["followers_count"].nil?
          assert channel.details.stats["followers_count"] < channels[index-1].details.stats["followers_count"]
        end
      end
    end

    describe 'video count' do
      it 'sorts by ascending' do
        channels = Channel.advanced_sort(Channel::VIDEO_COUNT, 'asc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["video_count"].nil?
          assert channel.details.stats["video_count"] > channels[index-1].details.stats["video_count"]
        end
      end

      it 'sorts by descending' do
        channels = Channel.advanced_sort(Channel::VIDEO_COUNT, 'desc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["video_count"].nil?
          assert channel.details.stats["video_count"] < channels[index-1].details.stats["video_count"]
        end
      end
    end

    describe 'subscriber count' do
      it 'sorts by ascending' do
        channels = Channel.advanced_sort(Channel::SUBSCRIBER_COUNT, 'asc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["subscriber_count"].nil?
          assert channel.details.stats["subscriber_count"] > channels[index-1].details.stats["subscriber_count"]
        end
      end

      it 'sorts by descending' do
        channels = Channel.advanced_sort(Channel::SUBSCRIBER_COUNT, 'desc')
        channels.each_with_index do |channel, index|
          next if index == 0 || channel.details.stats["subscriber_count"].nil?
          assert channel.details.stats["subscriber_count"] < channels[index-1].details.stats["subscriber_count"]
        end
      end
    end
  end

  # Maybe put this in a RegisterChannelForPromoJobTest?
  test "verifying a channel calls register_channel_for_promo (site)" do
    channel = channels(:default)
    publisher = channel.publisher
    publisher.promo_enabled_2018q1 = true
    publisher.save!

    # verify RegisterChannelForPromoJob is called
    channel.verified = true
    assert_enqueued_jobs(1) do
      channel.save!
    end

    # verify it worked and the channel has a referral code
    assert channel.promo_registration.referral_code

    # verify nothing happens if verified_changed? to false, or to true but not saved
    assert_enqueued_jobs(0) do
      channel.verified = false
      channel.save!
      channel.verified = true
    end
  end

  test "verifying a channel calls register_channel_for_promo (youtube)" do
    # To 'verify' a new youtube channel, we delete a previously verified channel then instantiate it
    channel_original = channels(:google_verified)
    publisher = channel_original.publisher

    # grab the details first, then destroy the original
    channel_details_copy = channel_original.details.dup
    channel_original.destroy!

    publisher.promo_enabled_2018q1 = true
    publisher.save!

    # check that RegisterChannelForPromoJob is called when it is verified
    # channel_copy.verified = true
    channel_copy = Channel.new(details: channel_details_copy, verified: true, publisher: publisher)
    assert_enqueued_jobs(1) do
      channel_copy.save!
    end

    assert channel_copy.promo_registration.referral_code
  end

  test "verification_failed! updates verification status" do
    channel = channels(:default)

    refute channel.verified?
    assert_nil channel.verified_at
    refute channel.verification_failed?

    channel.verification_failed!('no_https')

    refute channel.verified?
    assert_nil channel.verified_at
    assert channel.verification_failed?
    assert_equal 'no_https', channel.verification_details
  end

  test "verification_failed! updates verification status even with validation errors" do
    channel = channels(:fake1)

    refute channel.verified?
    assert_nil channel.verified_at
    refute channel.verification_failed?

    channel.verification_failed!('token_not_found_dns')

    refute channel.verified?
    assert_nil channel.verified_at
    assert channel.verification_failed?
    assert_equal 'token_not_found_dns', channel.verification_details
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

  test 'reverse verification' do
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
                                                            name: "twtwtw",
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
end
