module BrowserChannelsDynoCaching
  extend ActiveSupport::Concern

  def channels
    if dyno_cache_expired? || invalid_dyno_cache?
      p "Updating cache for #{self.class.to_s}"
      update_dyno_cache
    else
      p "cache hit on #{self.class.to_s}"
    end
    render(json: self.class.class_variable_get(klass_dyno_cache), status: 200)
  end

  private

  def dyno_cache_expired?
    expiration_time = Rails.cache.fetch(dyno_expiration_key)
    return expiration_time.nil? || Time.parse(expiration_time) <= Time.now
  end

  def invalid_dyno_cache?
    cached_dyno_value = self.class.class_variable_get(klass_dyno_cache)
    cached_dyno_value.nil? || !cached_dyno_value.is_a?(String)
  end

  def update_dyno_cache
    redis_value = Rails.cache.fetch(self.class::REDIS_KEY, race_condition_ttl: 30) do
      require 'sentry-raven'
      Raven.capture_message("Failed to use redis cache for Dyno cache: #{klass_dyno_cache}, continuing to read from cache instead")
    end
    if redis_value.present?
      self.class.class_variable_set(klass_dyno_cache, redis_value)
      Rails.cache.write(dyno_expiration_key, 1.hour.from_now.to_s, expires_in: 1.hour.from_now )
    end
  end

  def dyno_expiration_key
    raise "Define me for dyno_expiration_name!"
  end

  def klass_dyno_cache
    :@@cached_payload
  end
end
