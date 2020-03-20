module BrowserChannelsDynoCaching
  extend ActiveSupport::Concern
  require 'sentry-raven'

  def channels
    clear_if_old_lock
    have_lock = set_lock_to_now
    render(status: 429) and return unless have_lock
    if dyno_cache_expired? || invalid_dyno_cache?
      update_dyno_cache
    end
    render(json: self.class.class_variable_get(klass_dyno_cache), status: 200)
    Rails.cache.delete(self.class::REDIS_THUNDERING_HERD_KEY)
  end

  private

  def clear_if_old_lock
    past_time = Rails.cache.fetch(self.class::REDIS_THUNDERING_HERD_KEY)
    # It's about 55 MB, which should only take 10 seconds to transmit from endpoint to browser.
    if past_time.present? && 5.minutes.ago > Time.at(past_time)
      Rails.cache.delete(self.class::REDIS_THUNDERING_HERD_KEY)
    end
  end

  def set_lock_to_now
    Redis.new.setnx(self.class::REDIS_THUNDERING_HERD_KEY, Time.now.to_i)
  end

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
