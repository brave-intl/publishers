# frozen_string_literal: true

require "uri"
require "net/http"
require 'json'
require 'uri'
require 'digest'
require 'base64'

module Payment
  module Connection
    class BitflyerConnectionsController < ApplicationController
      class BitflyerError < StandardError; end
      before_action :authenticate_publisher!
      before_action :validate_connection!, only: :new

      def create
        BitflyerConnection.find_or_create_by(publisher: current_publisher)

        # Always send PKCE code verifier and challenge
        code_verifier = current_publisher.id
        code_challenge = Digest::SHA256.base64digest(code_verifier).chomp('=').gsub('+', '-').gsub('/', '_')
        pkce_string = '&code_challenge=' + code_challenge + '&code_challenge_method=S256'

        redirect_to Rails.application.secrets[:bitflyer_host] + '/ex/OAuth/authorize?client_id=' + Rails.application.secrets[:bitflyer_client_id] + '&scope=' + CGI.escape(Rails.application.secrets[:bitflyer_scope]) + '&redirect_uri=' + CGI.escape('https://' + Rails.application.secrets[:creators_host] + '/publishers/bitflyer_connection/new') + '&state=100&response_type=code' + pkce_string
      end

      # This action is after the OAuth connection is redirected.
      def edit
        bitflyer_connection = BitflyerConnection.find_by(publisher: current_publisher)

        # Request access token from bitFlyer.
        access_token_request_params = {
          'grant_type' => 'code',
          'code' => params[:code],
          'code_verifier' => current_publisher.id,
          'client_id' => Rails.application.secrets[:bitflyer_client_id],
          'client_secret' => Rails.application.secrets[:bitflyer_client_secret],
          'expires_in' => 259002,
          'external_acccount_id': current_publisher.id,
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

        # Add bitFlyer deposit id to each of the publisher's channels
        current_publisher.channels.each do |channel|
          # Intentional blocking call
          Sync::Bitflyer::UpdateMissingDepositJob.new.perform(channel.id)
        end

        if bitflyer_connection.update(update_bitflyer_connection_params) &&
          current_publisher.update(selected_wallet_provider: bitflyer_connection) &&
          redirect_to(home_publishers_path)
          return
        else
          redirect_to(home_publishers_path, alert: t(".gemini_error", message: gemini_connection.errors.full_messages.join(', ')))
          return
        end
      end

      def destroy
        I18n.locale = :ja
        bitflyer_connection = current_publisher.bitflyer_connection

        # Destroy our database records
        if bitflyer_connection.destroy
          redirect_to(home_publishers_path, notice: I18n.t("publishers.bitflyer_connections.destroy.removed"))
        else
          redirect_to(
            home_publishers_path,
            alert: I18n.t(
              "publishers.bitflyer_connections.destroy.error",
              errors: bitflyer_connection.errors.full_messages.join(', ')
            )
          )
        end
      end

      private

      def validate_connection!
        connection = current_publisher.bitflyer_connection

        raise BitflyerError.new, I18n.t('publishers.stripe_connections.new.missing_state') if connection&.state_token.blank?
        raise BitflyerError.new, I18n.t('publishers.stripe_connections.new.state_mismatch') if connection.state_token != params[:state]
        raise BitflyerError.new, params[:error] if params[:error].present?
      end
    end
  end
end
