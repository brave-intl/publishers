class Cache::BrowserChannels::PrefixList
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  # Might need to adjust the value based on 
  PREFIX_LENGTH = 9

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
    save_main_file!
    save_differential_file!
  end

  def save_main_file!
    result = ActiveRecord::Base.connection.execute("
        SELECT SUBSTRING(sha2_base16, 1, #{PREFIX_LENGTH})
        FROM site_banner_lookups
        WHERE wallet_status != #{PublishersPb::WalletConnectedState::NO_VERIFICATION}"
        ).map { |r| r['substring'] }.to_json
    temp_file = Tempfile.new(["all_channels", ".br"]).binmode
    temp_file.write(Brotli.deflate(result))
    temp_file.close
    save_to_s3!(temp_file_path: temp_file.path, save_to_filename: "all_channels.br")
    cleanup!(temp_file_path: temp_file.path)
  end

  def save_differential_file!
    date = Date.yesterday.strftime("%Y-%m-%d")
    result = ActiveRecord::Base.connection.execute("
        SELECT SUBSTRING(sha2_base16, 1, #{PREFIX_LENGTH})
        FROM site_banner_lookups
        WHERE wallet_status != #{PublishersPb::WalletConnectedState::NO_VERIFICATION}
        AND to_char(\"created_at\", 'YYYY-MM-DD') = '#{date}'"
        ).map { |r| r['substring'] }.to_json
    temp_file = Tempfile.new(["all_channels_#{date}", ".br"]).binmode
    temp_file.write(Brotli.deflate(result))
    temp_file.close
    save_to_s3!(temp_file_path: temp_file.path, save_to_filename: "all_channels_#{date}.br")
    cleanup!(temp_file_path: temp_file.path)
  end

  def cleanup!(temp_file_path:)
    # Closes and deletes the file
    Tempfile.open(temp_file_path).close!
  end

  def save_to_s3!(temp_file_path:, save_to_filename:)
    Aws.config[:credentials] = Aws::Credentials.new(Rails.application.secrets[:s3_rewards_access_key_id], Rails.application.secrets[:s3_rewards_secret_access_key])
    s3 = Aws::S3::Resource.new(region: Rails.application.secrets[:s3_rewards_bucket_region])
    obj = s3.bucket(Rails.application.secrets[:s3_rewards_bucket_name]).object(save_to_filename)
    obj.upload_file(temp_file_path)
  end
end
