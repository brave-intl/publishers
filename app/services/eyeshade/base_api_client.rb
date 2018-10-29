class Eyeshade::BaseApiClient < BaseApiClient
  attr_accessor :result

  def initialize
  end

  def perform
  end

  def perform_offline
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end

  def should_cache?
    false
  end

  def cache_key
    "unused"
  end

  def update_cache
    Rails.cache.write(cache_key, @result) if @result.present?
  end
end

