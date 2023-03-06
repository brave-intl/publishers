# typed: false

class LogException
  def self.perform(error, publisher: {}, params: {}, force: false, expected: false)
    if Rails.env.production? || Rails.env.staging? || force
      require "newrelic_rpm"
      NewRelic::Agent.notice_error(error, new_relic_params(publisher, params, expected: expected))
      true
    else
      Rails.logger.warn(error)
    end
  end

  def self.new_relic_params(publisher_params, params, expected:)
    {
      custom_params: params.merge(publisher: publisher_params, expected: expected)
    }
  end

  def self.sentry_params(publisher_params, params)
    {
      user: publisher_params,
      extra: params
    }
  end
end
