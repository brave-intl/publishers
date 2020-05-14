begin
  # Have to throw in a begin rescue block otherwise
  # Zeitwerk::NameError (expected file $DIR/protos/channel_responses.rb to define constant ChannelResponses, but didn't)
  # gets thrown.
  require './protos/publisher_list'
rescue
end
begin
  require './protos/channel_responses'
rescue
end

class Cache::BrowserChannels::PrefixList
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  # Might need to adjust the value based on 
  PREFIX_LENGTH = 9

  def perform
    # We only care about first PREFIX_LENGTH number of nibbles of the prefix.
    # Don't waste memory reading excess
    temp_file = save_main_file!
    save_to_s3!(temp_file_path: temp_file.path, save_to_filename: "prefixes")
    cleanup!(temp_file_path: temp_file)

    temp_file = save_differential_file!
    date = Date.yesterday.strftime("%Y-%m-%d")
    save_to_s3!(temp_file_path: temp_file.path, save_to_filename: "prefixes-#{date}")
    cleanup!(temp_file_path: temp_file)
  end

  def save_main_file!
    result = ActiveRecord::Base.connection.execute("
        SELECT SUBSTRING(sha2_base16, 1, #{PREFIX_LENGTH})
        FROM site_banner_lookups
        WHERE wallet_status != #{PublishersPb::WalletConnectedState::NO_VERIFICATION}"
        ).map { |r| r['substring'] }.to_json

    to_protobuf_file(result)
  end

  def save_differential_file!
    result = ActiveRecord::Base.connection.execute("
        SELECT SUBSTRING(sha2_base16, 1, #{PREFIX_LENGTH})
        FROM site_banner_lookups
        WHERE wallet_status != #{PublishersPb::WalletConnectedState::NO_VERIFICATION}
        AND to_char(\"created_at\", 'YYYY-MM-DD') = '#{date}'"
        ).map { |r| r['substring'] }.to_json

    to_protobuf_file(result)
  end

  def cleanup!(temp_file_path:)
    begin
      File.open(temp_file_path, 'r') do |f|
        File.delete(f)
      end
    rescue Errno::ENOENT
    end
  end

  def save_to_s3!(temp_file_path:, save_to_filename:)
    return if Rails.env.test?
    Aws.config[:credentials] = Aws::Credentials.new(Rails.application.secrets[:s3_rewards_access_key_id], Rails.application.secrets[:s3_rewards_secret_access_key])
    s3 = Aws::S3::Resource.new(region: Rails.application.secrets[:s3_rewards_bucket_region])
    obj = s3.bucket(Rails.application.secrets[:s3_rewards_bucket_name]).object(save_to_filename)
    obj.upload_file(temp_file_path)
  end

  private

  def to_protobuf_file(result)
    publisher_list_pb = PublishersPb::PublisherList.new
    publisher_list_pb.compression_type = PublishersPb::PublisherList::CompressionType::BROTLI_COMPRESSION
    publisher_list_pb.prefixes = Brotli.deflate(result)
    publisher_list_pb.prefix_size = PREFIX_LENGTH
    publisher_list_pb.uncompressed_size = result.length

    temp_file = Tempfile.new.binmode
    temp_file.write(PublishersPb::PublisherList.encode(publisher_list_pb))
    temp_file.close
    temp_file
  end
end
