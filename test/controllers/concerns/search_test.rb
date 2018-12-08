require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class SearchTest < ActionDispatch::IntegrationTest
  class Foo < ActionController::Base
    include Search
  end

  let(:controller) { Foo.new }

  describe 'extract_video_id' do
    it 'extracts youtube.com' do
      video_id = controller.send(:extract_video_id, 'youtube.com/watch?v=kLiLOkzLetE')
      assert_equal 'kLiLOkzLetE', video_id
    end

    it 'extracts youtube.com with parameters' do
      video_id = controller.send(:extract_video_id, 'youtube.com/watch?v=kLiLOkzLetE&feature=youtu.be&t=26')
      assert_equal 'kLiLOkzLetE', video_id
    end

    it 'extracts youtu.be' do
      video_id = controller.send(:extract_video_id, 'youtu.be/kLiLOkzLetE')
      assert_equal 'kLiLOkzLetE', video_id
    end

    it 'extracts youtu.be with parameters' do
      video_id = controller.send(:extract_video_id, 'youtu.be/kLiLOkzLetE?t=39')
      assert_equal 'kLiLOkzLetE', video_id
    end
  end

  describe 'is_youtube_video?' do
    it 'returns true when youtube video' do
      assert controller.send(:is_youtube_video?, 'youtube.com/watch?v=kLiLOkzLetE')
    end

    it 'returns true when youtu.be video' do
      assert controller.send(:is_youtube_video?, 'youtu.be/kLiLOkzLetE')
    end

    it 'returns false when youtube channel' do
      refute controller.send(:is_youtube_video?, 'youtube.com/channel/UCFNTTISby1c_H-rm5Ww5rZg')
    end

    it 'returns false when not youtube' do
      refute controller.send(:is_youtube_video?, 'twitter.com')
    end
  end

  describe 'channel_from_video_url' do
    let(:subject) { controller.remove_prefix_if_necessary('youtu.be/kLiLOkzLetE?t=39') }

    before do
      @prev_youtube = Rails.application.secrets[:youtube_api_key]
      Rails.application.secrets[:youtube_api_key] = nil
    end

    after do
      Rails.application.secrets[:youtube_api_key] = @prev_youtube
    end

    it 'extracts the channel_id from a youtube video' do
      assert_equal subject, 'channel_id'
    end
  end

  describe 'extract_channel_from_user' do
  end
end
