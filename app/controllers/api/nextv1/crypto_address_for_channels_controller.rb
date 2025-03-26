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
        ::Util::CryptoUtils.verify_solana_address(signature, account_address, message, current_publisher)
      when "ETH"
        ::Util::CryptoUtils.verify_ethereum_address(signature, account_address, message, current_publisher)
      else
        @errors << "address could not be verified"
        false
      end

    # check to make sure the address is not sanctioned
    sanctioned = sanctioned?(account_address)

    # Create new crypto address, and remove any other addresses on the same chain for the channel
    success = verified && !sanctioned && replace_crypto_address_for_channel(account_address, chain, current_channel)

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
      LogException.perform(e, publisher: current_publisher)
      render(json: {errors: "address could not be deleted"}, status: 400)
    end
  end

  private

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

  def sanctioned?(address)
    bucket_name = 'brave-production-ofac-addresses'
    encoded_address = Base64.urlsafe_encode64(address).gsub(/^=+|=+/)
    # Aws.config[:credentials] = Aws::Credentials.new(
    #   Rails.configuration.pub_secrets[:s3_rewards2_access_key_id],
    #   Rails.configuration.pub_secrets[:s3_rewards2_secret_access_key]
    # )    
    p encoded_address
    begin
      s3 = Aws::S3::Client.new
      s3.head_object(bucket: bucket_name, key: encoded_address)
      true
    rescue Aws::S3::Errors::NotFound
      false
    rescue Aws::S3::Errors::ServiceError => e # Catches other S3-related errors
      raise "S3 error while checking object existence: #{e.message}"
    end
  end
end
