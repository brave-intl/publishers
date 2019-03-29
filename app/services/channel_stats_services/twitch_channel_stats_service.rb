module ChannelStatsServices
  class TwitchChannelStatsService < BaseApiClient

    def initialize(twitch_channel_details:)
      @channel_details = twitch_channel_details
    end

    def perform
      return perform_offline if Rails.application.secrets[:api_twitch_base_uri].blank?
      stats = {
        "view_count": view_count,
        "followers_count": followers_count
      }

      @channel_details.stats = stats
      @channel_details.save!
    end

    def perform_offline
      true
    end

    private

    def view_count
      response = connection.get do |request|
        request.headers["Client-ID"] = api_authorization_header
        request.url("users?login=#{URI.escape(@channel_details.name)}")
      end

      rate_limit_reset_time = response.headers["Ratelimit-Reset"]
      time_to_wait = rate_limit_reset_time.to_i - Time.now.strftime('%s').to_i
      sleep time_to_wait

      @twitch_id = JSON.parse(response.body)["data"].first["id"]
      channel_view_count = JSON.parse(response.body)["data"].first["view_count"]
      channel_view_count
    end

    def followers_count
      response = connection.get do |request|
        request.headers["Client-ID"] = api_authorization_header
        request.url("users/follows?to_id=#{URI.escape(@twitch_id)}")
      end
      channel_followers_count = JSON.parse(response.body)["total"]
      channel_followers_count
    end

    def api_base_uri
      Rails.application.secrets[:api_twitch_base_uri]
    end

    def api_authorization_header
      Rails.application.secrets[:twitch_client_id]
    end
  end
end
