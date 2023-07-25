# typed: true

# MARKED FOR DEPRECATION:
# Any functionality in use here should be replaced by lib/eyeshade/client.rb
class Eyeshade::BaseApiClient < BaseApiClient
  attr_accessor :result

  def publishers
    @publishers ||= Eyeshade::Publishers.new
  end

  def referrals
    @referrals ||= Eyeshade::Referrals.new
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
