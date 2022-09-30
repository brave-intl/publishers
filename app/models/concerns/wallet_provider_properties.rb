# typed: false

module WalletProviderProperties
  extend ActiveSupport::Concern

  class BlockedCountryError < StandardError; end

  included do
    after_destroy :clear_selected_wallet_provider
  end

  def clear_selected_wallet_provider
    return unless publisher.selected_wallet_provider == self
    publisher.update(selected_wallet_provider: nil)
  end

  def check_country(country_code, provider_sym)
    parameters = Rewards::Parameters.new.get_parameters

    case parameters
    when Rewards::Types::ParametersResponse
      allowed_regions = parameters.custodianRegions
    else
      LogException.perform(parameters)
      raise StandardError.new("Could not load allowed regions")
    end
    unless allowed_regions[provider_sym][:allow].include?(country_code.upcase)
      raise BlockedCountryError.new("Your #{provider_sym.to_s.capitalize} account can't be connected to your Brave Creators" \
        " profile at this time. Your #{provider_sym.to_s.capitalize} account is registered in a country that's not currently " \
        "supported for connecting to Brave Creators.</br>See the <a target='_blank' href='https://support.brave.com/hc/en-us/articles/6539887971469'>" \
        "current list of supported regions and learn more</a> about connecting a custodial account to Brave Rewards.")
    end
  end
end
