class LogException
  def self.perform(error, publisher: {}, params: {}, force: false)
    if Rails.env.production? || Rails.env.staging? || force

      require 'newrelic_rpm'
      NewRelic::Agent.notice_error(error, new_relic_params(publisher, params))

      require 'sentry-raven'
      Raven.capture_exception(error, sentry_params(publisher, params))

      true
    end
  end

  def self.new_relic_params(publisher_params, params)
    {
      custom_params: params.merge(publisher: publisher_params)
    }
  end

  def self.sentry_params(publisher_params, params)
    {
      user: publisher_params,
      extra: params
    }
  end
end
