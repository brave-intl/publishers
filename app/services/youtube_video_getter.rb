class YoutubeChannelGetter < BaseApiClient
  attr_reader :token, :channel_id

  def initialize(token:, video_id: nil)
    @token = token
    @video_id = video_id
  end

  def perform
    return if video_id.empty?
    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("/youtube/v3/channels?id=#{channel_id}&part=statistics,snippet")
    end
    response_hash = JSON.parse(response.body)
    if response_hash['items']
      return response_hash['items'][0]
    else
      return nil
    end
  rescue Faraday::Error => e
    Rails.logger.warn("YoutubeChannelGetter #perform error: #{e}")
    case e.response[:status]
      when 403
        raise ForbiddenError.new(e.response[:body])
      when 404
        raise FoundError.new(e.response[:body])
      else
        raise BadRequestError.new(e.response[:body])
    end
  end

  private

  def api_base_uri
    "https://www.googleapis.com"
  end

  def api_authorization_header
    "Bearer #{token}"
  end

  class NotFoundError < RuntimeError
  end

  class ForbiddenError < RuntimeError
  end

  class BadRequestError < RuntimeError
  end
end
