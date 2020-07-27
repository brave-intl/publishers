module BrowserChannelsDynoCaching
  extend ActiveSupport::Concern
  require 'sentry-raven'

  PAGE_PREFIX = "_page_".freeze

  def channels
    clear_if_old_lock
    have_lock = set_lock_to_now
    render(status: 429) and return unless have_lock
=begin
  # Might be worth re-adding, but I think for now let's disable since we don't have overburdening memory
    if dyno_cache_expired? || invalid_dyno_cache?
      update_dyno_cache
    end
=end
    result = read_from_redis(page: params[:page]&.to_i)
    if result.nil?
      render(status: 204)
    else
      render(json: result, status: 200)
    end
    Rails.cache.delete(self.class::REDIS_THUNDERING_HERD_KEY)
  end

  private

  def read_from_redis(page: nil)
    if page.present?
      Rails.cache.fetch(self.class::REDIS_KEY + PAGE_PREFIX + page.to_s, race_condition_ttl: 30)
    else
      Rails.cache.fetch(self.class::REDIS_KEY, race_condition_ttl: 30)
    end
  end

  def clear_if_old_lock
    past_time = Rails.cache.fetch(self.class::REDIS_THUNDERING_HERD_KEY)
    # It's about 55 MB, which should only take 10 seconds to transmit from endpoint to browser.
    if past_time.present? && 5.minutes.ago > Time.at(past_time.to_i)
      Rails.cache.delete(self.class::REDIS_THUNDERING_HERD_KEY)
    end
  end

  def set_lock_to_now
    return true if Rails.application.secrets[:redis_url].blank?
    conn = Redis.new
    conn.setnx(self.class::REDIS_THUNDERING_HERD_KEY, Time.now.to_i)
    conn.quit
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
