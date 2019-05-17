require "test_helper"

describe GithubChannelDetails do
  let(:github_channel_details) { GithubChannelDetails.new }

  it "must be valid" do
    value(github_channel_details).must_be :valid?
  end
end
