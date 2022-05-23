# typed: ignore
# frozen_string_literal: true

require "uri"
require "net/http"
require "json"
require "digest"
require "base64"

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
        code_challenge = Digest::SHA256.base64digest(code_verifier).chomp("=").tr("+", "-").tr("/", "_")
        pkce_string = "&code_challenge=" + code_challenge + "&code_challenge_method=S256"

        redirect_to Rails.application.secrets[:bitflyer_host] + "/ex/OAuth/authorize?client_id=" + Rails.application.secrets[:bitflyer_client_id] + "&scope=" + CGI.escape(Rails.application.secrets[:bitflyer_scope]) + "&redirect_uri=" + CGI.escape("https://" + Rails.application.secrets[:creators_host] + "/publishers/bitflyer_connection/new") + "&state=100&response_type=code" + pkce_string
      end

      # This action is after the OAuth connection is redirected.
      def edit
        if Bitflyer::AuthCompleter.build.call(publisher: current_publisher, code: params[:code])
          redirect_to(home_publishers_path)
          return
        end

        redirect_to(home_publishers_path, alert: t("publishers.bitflyer_connections.new.bitflyer_error"))
      end

      def destroy
        I18n.locale = :ja
        bitflyer_connection = current_publisher.bitflyer_connection

        # Destroy our database records
        if bitflyer_connection.destroy
          redirect_to(home_publishers_path)
        else
          redirect_to(
            home_publishers_path,
            alert: I18n.t(
              "publishers.bitflyer_connections.destroy.error",
              errors: bitflyer_connection.errors.full_messages.join(", ")
            )
          )
        end
      end

      private

      def validate_connection!
        connection = current_publisher.bitflyer_connection

        raise BitflyerError.new, I18n.t("publishers.stripe_connections.new.missing_state") if connection&.state_token.blank?
        raise BitflyerError.new, I18n.t("publishers.stripe_connections.new.state_mismatch") if connection.state_token != params[:state]
        raise BitflyerError.new, params[:error] if params[:error].present?
      end
    end
  end
end
