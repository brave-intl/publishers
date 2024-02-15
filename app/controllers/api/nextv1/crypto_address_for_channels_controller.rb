require "eth"
require "rbnacl"
require "base58"

class Api::Nextv1::CryptoAddressForChannelsController < Api::Nextv1::BaseController
  include PublishersHelper
  include Eth

  def index
    current_channel = current_publisher.channels.find(params[:channel_id])
    @crypto_addresses_for_channel = CryptoAddressForChannel.where(channel: current_channel)
    render(json: @crypto_addresses_for_channel)
  end

  def generate_nonce
    nonce = SecureRandom.uuid
    Rails.cache.write(nonce, current_publisher.id)
    render json: {nonce: nonce}
  end

  def create
    signature = params[:transaction_signature]
    account_address = params[:account_address]
    chain = params[:chain]
    message = params[:message]
    current_channel = current_publisher.channels.find(params[:channel_id])
    @errors = []

    # check that the message is a valid nonce and delete after use
    valid_message = if Rails.cache.read(message) == current_publisher.id
      !!Rails.cache.delete(message)
    else
      @errors << "message is invalid"
      false
    end

    # check to make sure the user owns the address
    verified = valid_message &&
      case chain
      when "SOL"
        verify_solana_address(signature, account_address, message)
      when "ETH"
        verify_ethereum_address(signature, account_address, message)
      else
        @errors << "address could not be verified"
        false
      end

    # Create new crypto address, and remove any other addresses on the same chain for the channel
    success = verified && replace_crypto_address_for_channel(account_address, chain, current_channel)

    if success
      render(json: {crypto_address_for_channel: success}, status: 201)
    else
      render(json: {errors: @errors}, status: 400)
    end
  end

  def change_address
    account_address = params[:address]
    chain = params[:chain]
    current_channel = current_publisher.channels.find(params[:channel_id])

    success = replace_crypto_address_for_channel(account_address, chain, current_channel)

    if success
      render(json: {crypto_address_for_channel: success}, status: 200)
    else
      render(json: {errors: "address could not be updated"}, status: 400)
    end
  end

  def destroy
    chain = params[:chain]
    current_channel = current_publisher.channels.find(params[:channel_id])

    begin
      CryptoAddressForChannel.where(chain: chain, channel: current_channel).first&.destroy!
      render(json: {crypto_address_for_channel: true}, status: 200)
    rescue => e
      render(json: {errors: "address could not be deleted"}, status: 400)
    end
  end

  def verify_solana_address(signature, address, message)
    verify_key = RbNaCl::VerifyKey.new(Base58.base58_to_binary(address, :bitcoin))
    verify_key.verify(Base58.base58_to_binary(signature, :bitcoin), message)
  rescue => e
    LogException.perform(e, publisher: current_publisher)
    false
  end

  def verify_ethereum_address(signature, address, message)
    signature_pubkey = Eth::Signature.personal_recover message, signature
    signature_address = Eth::Util.public_key_to_address signature_pubkey
    # Eth addresses are case insensitive
    signature_address.address.downcase == address.downcase
  rescue => e
    LogException.perform(e, publisher: current_publisher)
    false
  end

  def replace_crypto_address_for_channel(account_address, chain, channel)
    ActiveRecord::Base.transaction do
      crypto_address = CryptoAddress.where(publisher: current_publisher, address: account_address, chain: chain, verified: true).first_or_create!
      existing_address = CryptoAddressForChannel.where(chain: chain, channel: channel)

      if existing_address.length > 0
        existing_address.first.destroy!
      end

      CryptoAddressForChannel.create!(chain: chain, crypto_address: crypto_address, channel: channel)
    end
  rescue => e
    LogException.perform(e, publisher: current_publisher)
    false
  end
  
end
