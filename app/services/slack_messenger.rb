# typed: true
# frozen_string_literal: true

class SlackMessenger < BaseApiClient
  attr_reader :channel, :message

  ALERTS = "creator-alerts"

  def can_perform?
    !!api_base_uri
  end

  def initialize(message:, channel: ALERTS, username: "coconut the dolphin", icon_emoji: ":coconut")
    @channel = channel
    @message = message
    @username = username
    @icon_emoji = icon_emoji
  end

  def perform
    if !can_perform?
      Rails.logger.info("SlackMessenger: Local notification: #{@message}")
      return
    end

    params = {
      "icon_emoji" => @icon_emoji,
      "username" => @username,
      "text" => @message
    }

    params["channel"] = @channel if @channel
    connection.post do |request|
      request.body = JSON.dump(params)
      request.url(api_base_uri)
    end
  end

  private

  def api_base_uri
    Rails.application.secrets[:slack_webhook_url]
  end

  def proxy_url
    nil
  end
end
