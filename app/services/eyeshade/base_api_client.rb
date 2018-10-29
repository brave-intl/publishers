class Eyeshade::BaseApiClient < BaseApiClient
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
end

