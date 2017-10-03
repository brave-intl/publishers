# https://devcenter.heroku.com/articles/dyno-metadata
message = "#{Socket.gethostname} publishers@#{ENV['HEROKU_SLUG_COMMIT']&.first(7)} #{ENV['HEROKU_RELEASE_VERSION']} started #{ENV['DYNO']}"

if Rails.env.production?
  begin
    SlackMessenger.new(
      channel: ENV["SLACK_CHANNEL_DIAGNOSTIC"].presence,
      message: message
    ).perform
  rescue Faraday::Error => e
    Rails.logger.warn("Couldn't notify Slack in notify_boot.rb: #{e}\n#{message} -- falling back to logger")
  end
end
