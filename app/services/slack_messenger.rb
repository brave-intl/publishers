# frozen_string_literal: true
class SlackMessenger < BaseApiClient
  attr_reader :channel, :message

  def can_perform?
    !!api_base_uri
  end

  def initialize(channel: nil, message:)
    @channel = channel
    @message = message
  end

  def perform
    if !can_perform?
      Rails.logger.debug("SlackMessenger: Local notification: #{message}")
      return
    end
    params = {
      "icon_emoji" => ":coconut:",
      "username" => "coconut the dolphin",
      "text" => message,
    }
    params["channel"] = channel if channel
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
