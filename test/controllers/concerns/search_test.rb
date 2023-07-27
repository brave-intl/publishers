# typed: false

require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class SearchTest < ActionDispatch::IntegrationTest
  class Foo < ActionController::Base
    include Search
  end

  let(:controller) { Foo.new }

  before do
    @prev_youtube = Rails.configuration.pub_secrets[:youtube_api_key]
  end

  after do
    Rails.configuration.pub_secrets[:youtube_api_key] = @prev_youtube
  end

  describe "extract_video_id" do
    it "extracts youtube.com" do
      video_id = controller.send(:extract_video_id, "youtube.com/watch?v=kLiLOkzLetE")
      assert_equal "kLiLOkzLetE", video_id
    end

    it "extracts youtube.com with parameters" do
      video_id = controller.send(:extract_video_id, "youtube.com/watch?v=kLiLOkzLetE&feature=youtu.be&t=26")
      assert_equal "kLiLOkzLetE", video_id
    end

    it "extracts youtu.be" do
      video_id = controller.send(:extract_video_id, "youtu.be/kLiLOkzLetE")
      assert_equal "kLiLOkzLetE", video_id
    end

    it "extracts youtu.be with parameters" do
      video_id = controller.send(:extract_video_id, "youtu.be/kLiLOkzLetE?t=39")
      assert_equal "kLiLOkzLetE", video_id
    end
  end

  describe "is_youtube_video?" do
    it "returns true when youtube video" do
      assert controller.send(:is_youtube_video?, "youtube.com/watch?v=kLiLOkzLetE")
    end

    it "returns true when youtu.be video" do
      assert controller.send(:is_youtube_video?, "youtu.be/kLiLOkzLetE")
    end

    it "returns false when youtube channel" do
      refute controller.send(:is_youtube_video?, "youtube.com/channel/UCFNTTISby1c_H-rm5Ww5rZg")
    end

    it "returns false when not youtube" do
      refute controller.send(:is_youtube_video?, "twitter.com")
    end
  end

  describe "extract_channel" do
    it "extracts channel id" do
      channel_id = controller.send(:extract_channel, "youtube.com/channel/UCFNTTISby1c_H-rm5Ww5rZg")
      assert_equal "UCFNTTISby1c_H-rm5Ww5rZg", channel_id
    end

    it "extracts channel id with parameters" do
      channel_id = controller.send(:extract_channel, "youtube.com/channel/UCFNTTISby1c_H-rm5Ww5rZg&with_params")
      assert_equal "UCFNTTISby1c_H-rm5Ww5rZg", channel_id
    end
  end

  describe "extract_channel_from_user" do
    it "extracts channel from username" do
      Rails.configuration.pub_secrets[:youtube_api_key] = nil
      channel_id = controller.send(:extract_channel_from_user, "youtube.com/user/BartBaKer")
      assert_equal "channel_id", channel_id
    end

    it "extracts channel id with parameters" do
      Rails.configuration.pub_secrets[:youtube_api_key] = nil
      channel_id = controller.send(:extract_channel_from_user, "youtube.com/user/BartBaKer/videos")
      assert_equal "channel_id", channel_id
    end

    describe "extract channel from user mock" do
      let(:user) { "not found" }

      before do
        stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?part=id&forUsername=#{user}&key=key")
          .to_return(status: 200, body: '{ "items": [] }')
      end

      it "returns empty string when user is not found" do
        Rails.configuration.pub_secrets[:youtube_api_key] = "key"
        channel_id = controller.send(:extract_channel_from_user, "youtube.com/user/#{user}/videos")
        assert_equal channel_id, ""
      end
    end
  end
end
