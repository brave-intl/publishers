class YoutubeChannelGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:, token:, channel_id: nil)
    @publisher = publisher
    @token = token
    @channel_id = channel_id
  end

  def perform
    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      if @channel_id
        request.url("/youtube/v3/channels?id=#{@channel_id}&part=statistics,snippet")
      else
        request.url("/youtube/v3/channels?mine=true&part=statistics,snippet")
      end
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
        raise ChannelForbiddenError.new(e.response[:body])
      when 404
        raise ChannelNotFoundError.new(e.response[:body])
      else
        raise ChannelBadRequestError.new(e.response[:body])
    end
  end

  private

  def api_base_uri
    "https://www.googleapis.com"
  end

  def api_authorization_header
    "Bearer #{@token}"
  end

  class ChannelNotFoundError < RuntimeError
  end

  class ChannelForbiddenError < RuntimeError
  end

  class ChannelBadRequestError < RuntimeError
  end
end
