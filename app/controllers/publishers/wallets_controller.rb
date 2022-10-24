# typed: ignore

module Publishers
  class WalletsController < ApplicationController
    before_action :authenticate_publisher!

    def show
      wallet = current_publisher.wallet
      head 404 and return if wallet.blank?

      wallet_data = {
        wallet: wallet,
        uphold_connection: uphold_wallet,
        gemini_connection: gemini_wallet,
        bitflyer_connection: bitflyer_wallet
      }

      render(json: wallet_data)
    end

    # Public: Requests the Publisher's latest transactions from Eyeshade
    #
    # Returns the latest settled payment in JSON
    def latest
      wallet = PublisherWalletGetter.new(
        publisher: current_publisher,
        include_transactions: true
      ).perform

      render json: {lastSettlement: wallet.last_settlement_balance}
    end

    private

    # Internal: Renders properties associated with an Uphold Wallet Connection
    #
    # Returns a hash
    def uphold_wallet
      current_publisher.uphold_connection.as_json(
        only: [:default_currency, :uphold_id, :is_member, :oauth_refresh_failed],
        methods: [:can_create_uphold_cards?, :username, :uphold_status, :verify_url]
      )
    end

    # Internal: Renders properties associated with the Gemini Wallet Connection
    #
    # Returns a hash
    def gemini_wallet
      current_publisher.gemini_connection.as_json(
        only: [:default_currency, :display_name, :recipient_id, :oauth_refresh_failed, :recipient_id_status],
        methods: [:payable?, :verify_url, :valid_country?]
      )
    end

    # Internal: Renders properties associated with the Bitflyer Wallet Connection
    #
    # Returns a hash
    def bitflyer_wallet
      current_publisher.bitflyer_connection.as_json(
        only: [:default_currency, :display_name, :recipient_id, :oauth_refresh_failed],
        methods: [:payable?, :verify_url]
      )
    end
  end
end
