class YoutubeUserGetter < BaseApiClient
  def initialize(user: nil)
    @user = user
  end

  def perform
    return perform_offline if Rails.application.secrets[:youtube_api_key].blank?

    response = connection.get do |request|
      request.url("/youtube/v3/channels?part=id&forUsername=#{@user}&key=#{Rails.application.secrets[:youtube_api_key]}")
    end
    response_hash = JSON.parse(response.body)
    if response_hash["items"]
      response_hash['items'][0]&.fetch("id")
    end
  rescue Faraday::Error => e
    Rails.logger.warn("YoutubeUserGetter #perform error: #{e}")
  end

  def api_base_uri
    "https://www.googleapis.com"
  end

  def perform_offline
    "channel_id"
  end
end
