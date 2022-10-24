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

  def valid_country?(country_code, provider_sym)
    parameters = Rewards::Parameters.new.get_parameters

    case parameters
    when Rewards::Types::ParametersResponse
      allowed_regions = parameters.custodianRegions
    else
      LogException.perform(parameters)
      raise StandardError.new("Could not load allowed regions")
    end

    allowed_regions[provider_sym][:allow].include?(country_code.upcase)
  end

  def check_country(country_code, provider_sym)
    unless valid_country?(country_code, provider_sym)
      raise BlockedCountryError.new(I18n.t("publishers.wallet_connection.blocked_country_error",
        provider: provider_sym.to_s.capitalize,
        support_post: "https://support.brave.com/hc/en-us/articles/6539887971469")
                                    .html_safe)
    end
  end
end
