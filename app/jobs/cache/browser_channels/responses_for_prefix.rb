# typed: ignore

class Cache::BrowserChannels::ResponsesForPrefix
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: true

  PATH = "publishers/prefixes/".freeze
  PADDING_WORD = "P".freeze
  BITFLYER_CONNECTION = "BitflyerConnection".freeze
  UPHOLD_CONNECTION = "UpholdConnection".freeze
  GEMINI_CONNECTION = "GeminiConnection".freeze

  attr_accessor :site_banner_lookups, :temp_file

  def perform(prefix)
    return if Rails.env.development?
    ActiveRecord::Base.connected_to(role: :reading) do
      generate_brotli_encoded_channel_response(prefix: prefix)
    end
    pad_file!
    save_to_s3!(prefix: prefix) unless Rails.env.test?
    cleanup!
  end

  def generate_brotli_encoded_channel_response(prefix:)
    @site_banner_lookups = SiteBannerLookup.where("sha2_base16 LIKE ?", prefix + "%")
    channel_responses = PublishersPb::ChannelResponseList.new

    allowed_regions = Rewards::Parameters.new.fetch_allowed_regions

    @site_banner_lookups.includes(publisher: [:uphold_connection, :bitflyer_connection, :gemini_connection]).each do |site_banner_lookup|
      channel_response = PublishersPb::ChannelResponse.new
      channel_response.channel_identifier = site_banner_lookup.channel_identifier
      # Some malformed data shouldn't prevent the list from being generated.
      begin
        if site_banner_lookup.publisher.selected_wallet_provider_type == UPHOLD_CONNECTION && site_banner_lookup.publisher.uphold_connection.present?
          wallet = PublishersPb::Wallet.new
          uphold_wallet = PublishersPb::UpholdWallet.new
          connection = site_banner_lookup.publisher.uphold_connection
          uphold_wallet.wallet_state = get_uphold_wallet_state(uphold_connection: connection)

          if connection.country && allowed_regions[:uphold][:allow].include?(connection.country.upcase)
            uphold_address = site_banner_lookup.channel.uphold_connection&.address
            if uphold_address
              uphold_wallet.address = uphold_address
            end
          end

          wallet.uphold_wallet = uphold_wallet
          channel_response.wallets.push(wallet)
        end
        if site_banner_lookup.publisher.selected_wallet_provider_type == BITFLYER_CONNECTION && site_banner_lookup.publisher.bitflyer_connection.present?
          wallet = PublishersPb::Wallet.new
          bitflyer_wallet = PublishersPb::BitflyerWallet.new
          connection = site_banner_lookup.publisher.bitflyer_connection
          bitflyer_wallet.wallet_state = get_bitflyer_wallet_state(bitflyer_connection: connection)
          bitflyer_wallet.address = site_banner_lookup.channel.deposit_id

          wallet.bitflyer_wallet = bitflyer_wallet
          channel_response.wallets.push(wallet)
        end
        if site_banner_lookup.publisher.selected_wallet_provider_type == GEMINI_CONNECTION && site_banner_lookup.publisher.gemini_connection.present?
          wallet = PublishersPb::Wallet.new
          gemini_wallet = PublishersPb::GeminiWallet.new
          connection = site_banner_lookup.publisher.gemini_connection
          gemini_wallet.wallet_state = get_gemini_wallet_state(gemini_connection: connection)

          if connection.country && allowed_regions[:gemini][:allow].include?(connection.country.upcase)
            gemini_address = site_banner_lookup.channel.gemini_connection&.recipient_id
            if gemini_address
              gemini_wallet.address = gemini_address
            end
          end

          wallet.gemini_wallet = gemini_wallet
          channel_response.wallets.push(wallet)
        end
      rescue => e
        LogException.perform(e)
      end
      channel_response.site_banner_details = get_site_banner_details(site_banner_lookup)
      channel_responses.channel_responses.push(channel_response)
    end

    json = PublishersPb::ChannelResponseList.encode(channel_responses)
    info = Brotli.deflate(json)
    @temp_file = Tempfile.new.binmode

    # Write a 4-byte header saying the payload length
    @temp_file.write([info.length].pack("N"))
    @temp_file.write(info)
    @temp_file.close
    @temp_file
  end

  private

  def get_uphold_wallet_state(uphold_connection:)
    if uphold_connection.is_member && uphold_connection.address.present?
      PublishersPb::UpholdWalletState::UPHOLD_ACCOUNT_KYC
    else
      PublishersPb::UpholdWalletState::UPHOLD_ACCOUNT_NO_KYC
    end
  end

  def get_paypal_wallet_state(paypal_connection:)
    if paypal_connection.verified_account?
      PublishersPb::PaypalWalletState::PAYPAL_ACCOUNT_KYC
    else
      PublishersPb::PaypalWalletState::PAYPAL_ACCOUNT_NO_KYC
    end
  end

  def get_bitflyer_wallet_state(bitflyer_connection:)
    PublishersPb::BitflyerWalletState::BITFLYER_ACCOUNT_KYC
  end

  def get_gemini_wallet_state(gemini_connection:)
    if gemini_connection.payable?
      PublishersPb::GeminiWalletState::GEMINI_ACCOUNT_KYC
    else
      PublishersPb::GeminiWalletState::GEMINI_ACCOUNT_NO_KYC
    end
  end

  def cleanup!
    File.open(@temp_file.path, "r") do |f|
      File.delete(f)
    end
  rescue Errno::ENOENT
  end

  # We want to hide which file is being downloaded by making all requests be the same size
  def pad_file!
    path = @temp_file.path
    # Round up to nearest KB
    file_size = File.size(path)
    # Converts size from like 326 to 1000
    new_size = (((file_size + 1000) / 1000)) * 1000
    delta = new_size - file_size
    # I'm assuming padding will be fast in a for loop, this can be optimized if this is slow
    # if moving around the file on disk is a frequent operation
    File.open(path, "ab") do |f|
      f.write(PADDING_WORD * delta)
      f.close
    end
  end

  def save_to_s3!(prefix:)
    path = @temp_file.path
    Aws.config[:credentials] = Aws::Credentials.new(
      Rails.application.secrets[:s3_rewards2_access_key_id],
      Rails.application.secrets[:s3_rewards2_secret_access_key]
    )

    s3 = Aws::S3::Resource.new(region: Rails.application.secrets[:s3_rewards2_bucket_region])
    obj = s3.bucket(Rails.application.secrets[:s3_rewards2_bucket_name]).object(PATH + prefix)
    obj.upload_file(path)
  end

  def get_site_banner_details(site_banner_lookup)
    details = PublishersPb::SiteBannerDetails.new
    site_banner_lookup.derived_site_banner_info.keys.each do |key|
      # Convert to snake_case
      value = site_banner_lookup.derived_site_banner_info[key]
      next if value.nil? || value.is_a?(Hash) || value.is_a?(Array)
      details[key.underscore] = value
    end

    if site_banner_lookup.derived_site_banner_info["donationAmounts"].present? && site_banner_lookup.derived_site_banner_info["donationAmounts"] != SiteBanner::DEFAULT_AMOUNTS
      # Confusing. This is the suggested implementation (no, normal assignment doesn't work)
      # https://github.com/protocolbuffers/protobuf/issues/320
      details.donation_amounts += site_banner_lookup.derived_site_banner_info["donationAmounts"]
    end

    if site_banner_lookup.derived_site_banner_info["socialLinks"].present?
      social_links_pb = nil
      site_banner_lookup.derived_site_banner_info["socialLinks"].each do |domain, handle|
        if handle.present?
          social_links_pb = PublishersPb::SocialLinks.new if social_links_pb.nil?
          social_links_pb[domain] = handle
        end
      end
      details.social_links = social_links_pb if social_links_pb.present?
    end
    details
  end
end
