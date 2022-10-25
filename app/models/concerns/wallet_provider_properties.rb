# typed: false

module WalletProviderProperties
  extend ActiveSupport::Concern
  include Oauth2::Errors

  class BlockedCountryError < ConnectionError; end

  included do
    after_destroy :clear_selected_wallet_provider
  end

  def clear_selected_wallet_provider
    return unless publisher.selected_wallet_provider == self
    publisher.update(selected_wallet_provider: nil)
  end

  def allowed_countries
    # fetch cached regions
    allowed_regions = Rewards::Parameters.new.fetch_allowed_regions(true)
    allowed_regions[provider_sym][:allow]
  end

  def valid_country?
    allowed_countries.include?(country&.upcase)
  end
end
