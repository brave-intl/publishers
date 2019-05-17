require "test_helper"

describe RedditChannelDetails do
  let(:reddit_channel_details) { RedditChannelDetails.new }

  it "must be valid" do
    value(reddit_channel_details).must_be :valid?
  end
end
