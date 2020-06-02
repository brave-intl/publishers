class Cache::BrowserChannels::PrefixList
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  # Might need to adjust the value based on collision rate
  PREFIX_LENGTH = 4

  attr_reader :compression_type

  def initialize(compression_type: PublishersPb::PublisherList::CompressionType::BROTLI_COMPRESSION)
    @compression_type = compression_type
  end

  def perform
    # We only care about first PREFIX_LENGTH number of nibbles of the prefix.
    # Don't waste memory reading excess
    temp_file = save_main_file!
    save_to_s3!(temp_file_path: temp_file.path, save_to_filename: "prefixes")
    cleanup!(temp_file_path: temp_file)

    date = Date.yesterday.strftime("%Y-%m-%d")
    temp_file = save_differential_file!(date: date)
    save_to_s3!(temp_file_path: temp_file.path, save_to_filename: "prefixes-#{date}") # 2020-05-17
    cleanup!(temp_file_path: temp_file)
  end

  def save_main_file!
    result = SiteBannerLookup.find_by_sql(["
        SELECT SUBSTRING(sha2_base16, 1, :nibble_length)
        FROM site_banner_lookups
        WHERE wallet_status != :not_verified_wallet_state",
        {
          nibble_length: PREFIX_LENGTH * 2,
          not_verified_wallet_state: PublishersPb::WalletConnectedState::NO_VERIFICATION
        }
    ]).map { |r| r['substring'] }.sort!

    to_protobuf_file(result)
  end

  def save_differential_file!(date:)
    result = SiteBannerLookup.find_by_sql(["
        SELECT SUBSTRING(sha2_base16, 1, :nibble_length)
        FROM site_banner_lookups
        WHERE wallet_status != :not_verified_wallet_state
        AND to_char(\"created_at\", 'YYYY-MM-DD') = :date",
        {
          nibble_length: PREFIX_LENGTH * 2,
          not_verified_wallet_state: PublishersPb::WalletConnectedState::NO_VERIFICATION,
          date: date
        }
    ]).map { |r| r['substring'] }.sort!

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
    Aws.config[:credentials] = Aws::Credentials.new(Rails.application.secrets[:s3_rewards2_access_key_id], Rails.application.secrets[:s3_rewards2_secret_access_key])
    s3 = Aws::S3::Resource.new(region: Rails.application.secrets[:s3_rewards2_bucket_region])
    obj = s3.bucket(Rails.application.secrets[:s3_rewards2_bucket_name]).object(save_to_filename)
    obj.upload_file(temp_file_path)
  end

  private

  def to_protobuf_file(result)
    publisher_list_pb = PublishersPb::PublisherList.new
    publisher_list_pb.compression_type = @compression_type
    if @compression_type == PublishersPb::PublisherList::CompressionType::NO_COMPRESSION
      publisher_list_pb.prefixes = result.map { |item| [item].pack('H*') }.join("")
      publisher_list_pb.uncompressed_size = publisher_list_pb.prefixes.length
    elsif @compression_type == PublishersPb::PublisherList::CompressionType::BROTLI_COMPRESSION
      new_result = result.map { |item| [item].pack('H*') }.join("")
      publisher_list_pb.prefixes = Brotli.deflate(new_result)
      publisher_list_pb.uncompressed_size = new_result.length
    end
    publisher_list_pb.prefix_size = PREFIX_LENGTH
    temp_file = Tempfile.new.binmode
    temp_file.write(PublishersPb::PublisherList.encode(publisher_list_pb))
    temp_file.close
    temp_file
  end
end
