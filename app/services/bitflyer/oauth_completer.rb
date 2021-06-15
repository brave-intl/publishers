# frozen_string_literal: true

module Bitflyer
  class OauthCompleter
    def self.build
      new
    end

    # After the user redirects to us for Oauth completion -- with the access_token, refresh_token
    def call(publisher:, code:)
      bitflyer_connection = BitflyerConnection.find_by(publisher: publisher)

      # Request access token from bitFlyer.
      access_token_request_params = {
        'grant_type' => 'code',
        'code' => code,
        'code_verifier' => publisher.id,
        'client_id' => Rails.application.secrets[:bitflyer_client_id],
        'client_secret' => Rails.application.secrets[:bitflyer_client_secret],
        'expires_in' => 259002,
        'external_acccount_id': publisher.id,
        'request_id': SecureRandom.uuid,
        'redirect_uri': 'https://' + Rails.application.secrets[:creators_host] + '/publishers/bitflyer_connection/new',
        'request_deposit_id': true,
      }

      # TODO: Bitflyer should provide a display name in this request response.
      response = Net::HTTP.post_form(URI.parse(Rails.application.secrets[:bitflyer_host] + '/api/link/v1/token'), access_token_request_params)

      access_token = JSON.parse(response.body)["access_token"]
      refresh_token = JSON.parse(response.body)["refresh_token"]
      display_name = JSON.parse(response.body)["account_hash"]

      # TODO: Does bitFlyer support changes of default currency?
      update_bitflyer_connection_params = {
        access_token: access_token,
        refresh_token: refresh_token,
        display_name: display_name,
        default_currency: "BAT",
      }

      if bitflyer_connection.update(update_bitflyer_connection_params) &&
        publisher.update(selected_wallet_provider: bitflyer_connection) &&

        # Add bitFlyer deposit id to each of the publisher's channels
        publisher.channels.each do |channel|
          # Intentional blocking call
          Sync::Bitflyer::UpdateMissingDepositJob.new.perform(channel.id)
        end
        return true
      end
      false
    end
  end
end
