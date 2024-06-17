class Api::Nextv1::HomeController < Api::Nextv1::BaseController
  include PublishersHelper

  def dashboard
    publisher = current_publisher.as_json(only: [:id], methods: [:brave_payable?])
    channels = current_publisher.channels.visible.as_json(only: [:details_type, :id, :verified, :verification_status, :verification_details],
      methods: [:failed_verification_details, :failed_verification_call_to_action],
      include: {
        details: {only: [], methods: [:publication_title]}
      })
    wallet = PublisherWalletGetter.new(
      publisher: current_publisher,
      include_transactions: true
    ).perform
    regions = Rewards::Parameters.new.fetch_allowed_regions

    wallet_data = {
      wallet: wallet,
      uphold_connection: uphold_wallet,
      gemini_connection: gemini_wallet,
      bitflyer_connection: bitflyer_wallet,
      allowed_regions: regions,
      next_deposit_date: next_deposit_date
    }

    response_data = {
      publisher: publisher,
      channels: channels,
      wallet_data: wallet_data
    }

    render(json: response_data.to_json, status: 200)
  end

  # TODO: figure out if we need the 'latest' endpoint
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
      only: [:default_currency, :uphold_id, :is_member, :oauth_refresh_failed, :payout_failed],
      methods: [:can_create_uphold_cards?, :username, :uphold_status, :verify_url]
    )
  end

  # Internal: Renders properties associated with the Gemini Wallet Connection
  #
  # Returns a hash
  def gemini_wallet
    current_publisher.gemini_connection.as_json(
      only: [:default_currency, :display_name, :recipient_id, :oauth_refresh_failed, :recipient_id_status, :payout_failed],
      methods: [:payable?, :verify_url, :valid_country?]
    )
  end

  # Internal: Renders properties associated with the Bitflyer Wallet Connection
  #
  # Returns a hash
  def bitflyer_wallet
    current_publisher.bitflyer_connection.as_json(
      only: [:default_currency, :display_name, :recipient_id, :oauth_refresh_failed, :payout_failed],
      methods: [:payable?, :verify_url]
    )
  end
end