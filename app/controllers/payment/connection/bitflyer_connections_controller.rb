# frozen_string_literal: true

require "uri"
require "net/http"
require 'json'

module Payment
  module Connection
    class BitflyerConnectionsController < ApplicationController
      class BitflyerError < StandardError; end
      before_action :authenticate_publisher!
      before_action :validate_connection!, only: :new

      def create
        BitflyerConnection.find_or_create_by(publisher: current_publisher)
        redirect_to "http://demo22oy5z2d2lu6pyoum26m7k.azurewebsites.net/ex/OAuth/authorize?client_id=6cd6f1a070afcd467e198c8039b2c97b&scope=assets+create_deposit_id+withdraw_to_deposit_id&redirect_uri=https%3A%2F%2Flocalhost%3A3000%2Fpublisher%2Fbitflyer_connection%2Fnew&state=100&response_type=code"
      end

      # This action is after the OAuth connection is redirected.
      def edit
        bitflyer_connection = BitflyerConnection.find_by(publisher: current_publisher)
        auth_code = params[:code]
        pub_id = current_publisher.id
        request_id = SecureRandom.uuid
        request_id2 = SecureRandom.uuid

        puts params[:code]
        puts "^ this is the AUTHORIZATION CODE from bitFlyer Auth"

        params = {
          'grant_type' => 'code',
          'code' => auth_code,
          'client_id' => '6cd6f1a070afcd467e198c8039b2c97b',
          'client_secret' => '8862095b1d7ead05ccd7044ad70d43bfe4b1964b297db4536acf46b26259aa42',
          'expires_in' => 259002,
          'external_acccount_id': pub_id,
          'request_id': request_id,
          'redirect_uri': 'https://localhost:3000/publisher/bitflyer_connection/new',
          'request_deposit_id': true,
        }
        x = Net::HTTP.post_form(URI.parse('https://demo22OY5Z2d2lU6PYoUm26m7k.azurewebsites.net/api/link/v1/token'), params)
        puts JSON.parse(x.body)["access_token"]

        puts "Access token ^^"

        access_token = JSON.parse(x.body)["access_token"]
        refresh_token = JSON.parse(x.body)["refresh_token"]

        url = URI.parse('https://demo22OY5Z2d2lU6PYoUm26m7k.azurewebsites.net/api/link/v1/account/create-deposit-id?request_id=' + request_id2)
        req = Net::HTTP::Get.new(url.to_s)
        req['Authorization'] = "Bearer " + access_token

        res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
          http.request(req)
        end

        puts JSON.parse(res.body)

        deposit_id = JSON.parse(res.body)["deposit_id"]
        puts deposit_id

        puts "Deposit id ^^"

        update_params = {
          access_token: access_token,
          refresh_token: refresh_token,
        }

        if bitflyer_connection.update(update_params) &&
          current_publisher.update(selected_wallet_provider: bitflyer_connection) &&
          current_publisher.update(bitflyer_deposit_id: deposit_id) &&
          redirect_to(home_publishers_path)
          return
        else
          redirect_to(home_publishers_path, alert: t(".gemini_error", message: gemini_connection.errors.full_messages.join(', ')))
          return
        end
      end

      def destroy
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
