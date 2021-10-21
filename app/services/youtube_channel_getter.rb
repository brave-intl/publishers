require "sentry-raven"

class YoutubeChannelGetter < BaseApiClient
  attr_reader :token, :channel_id

  def initialize(token:, channel_id: nil)
    @token = token
    @channel_id = channel_id
  end

  def perform
    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      if channel_id
        request.url("/youtube/v3/channels?id=#{channel_id}&part=statistics,snippet")
      else
        request.url("/youtube/v3/channels?mine=true&part=statistics,snippet")
      end
    end
    response_hash = JSON.parse(response.body)
    if response_hash["items"]
      response_hash["items"][0]
    end
  rescue Faraday::Error => e
    Rails.logger.warn("YoutubeChannelGetter #perform error: #{e}")
    Raven.capture_exception(e)
    case e.response[:status]
      when 403
        new_exception = ChannelForbiddenError.new(e.response[:body])
        Raven.capture_exception(new_exception)
        raise new_exception
      when 404
        new_exception = ChannelNotFoundError.new(e.response[:body])
        Raven.capture_exception(new_exception)
        raise new_exception
      else
        new_exception = ChannelBadRequestError.new(e.response[:body])
        Raven.capture_exception(new_exception)
        raise new_exception
    end
  end

  private

  def api_base_uri
    "https://www.googleapis.com"
  end

  def api_authorization_header
    "Bearer #{token}"
  end

  class ChannelNotFoundError < RuntimeError
  end

  class ChannelForbiddenError < RuntimeError
  end

  class ChannelBadRequestError < RuntimeError
  end
end
