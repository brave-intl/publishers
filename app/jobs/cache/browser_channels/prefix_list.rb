class Cache::BrowserChannels::PrefixList
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  # Might need to adjust the value based on 
  PREFIX_LENGTH = 9
  ALL_CHANNELS_KEY = "all_channels"
  EXTENSION = ".br"

  def perform
    begin
      # Have to throw in a begin rescue block otherwise
      # Zeitwerk::NameError (expected file $DIR/protos/channel_responses.rb to define constant ChannelResponses, but didn't)
      # gets thrown.
      require './protos/channel_responses'
    rescue
    end
    # We only care about first PREFIX_LENGTH number of nibbles of the prefix.
    # Don't waste memory reading excess
    result = ActiveRecord::Base.connection.execute("
        SELECT SUBSTRING(sha2_base16, 1, #{PREFIX_LENGTH})
        FROM site_banner_lookups
        WHERE wallet_status != #{PublishersPb::WalletConnectedState::NO_VERIFICATION}"
        ).map! { |r| r['substring'] }.to_json
    require 'brotli'
    @temp_file = Tempfile.new(["all_channels", ".br"])
    @temp_file.binmode
    @temp_file.write(Brotli.deflate(result))
    save_to_s3!
    cleanup!
  end

  def cleanup!
    temp_file.close
    temp_file.unlink
  end

  def save_to_s3!
    Aws.config[:credentials] = Aws::Credentials.new(Rails.application.secrets[:s3_rewards_access_key_id], Rails.application.secrets[:s3_rewards_secret_access_key])
    s3 = Aws::S3::Resource.new(region: Rails.application.secrets[:s3_rewards_bucket_region])
    obj = s3.bucket(Rails.application.secrets[:s3_rewards_bucket_name]).object(ALL_CHANNELS_KEY + EXTENSION)
    obj.upload_file(@temp_file.path)
  end
end
