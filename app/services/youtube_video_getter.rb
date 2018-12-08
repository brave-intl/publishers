class YoutubeVideoGetter < BaseApiClient
  attr_reader :token, :channel_id

  def initialize(id: nil)
    @id = id
  end

  def perform
    return perform_offline if Rails.application.secrets[:youtube_api_key].blank?

    Yt::Video.new(id: @id).channel_id
  end

  def perform_offline
    "channel_id"
  end
end
