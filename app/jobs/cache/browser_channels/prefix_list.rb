class Cache::BrowserChannels::PrefixList
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: true

  # Might need to adjust the value based on collision rate
  PREFIX_LENGTH = 4

  attr_reader :compression_type

  def initialize(compression_type: PublishersPb::PublisherPrefixList::CompressionType::BROTLI_COMPRESSION)
    @compression_type = compression_type
  end

  def perform
    # We only care about first PREFIX_LENGTH number of nibbles of the prefix.
    # Don't waste memory reading excess
    temp_file = save_main_file!
    save_to_s3!(temp_file_path: temp_file.path, save_to_filename: "publishers/prefix-list")
    cleanup!(temp_file_path: temp_file)

    date = Date.yesterday.strftime("%Y-%m-%d")
    temp_file = save_differential_file!(date: date)
    save_to_s3!(temp_file_path: temp_file.path, save_to_filename: "publishers/prefix-list-#{date}") # 2020-05-17
    cleanup!(temp_file_path: temp_file)
  end

  def save_main_file!
    result = SiteBannerLookup.find_by_sql(["
        SELECT SUBSTRING(sha2_base16, 1, :nibble_length)
        FROM site_banner_lookups",
        {
          nibble_length: PREFIX_LENGTH * 2,
        }
    ]).map { |r| r['substring'] }.uniq.sort!

    if Rails.env.staging?
      # Insert a million entries. First preallocate the space then fill the entries
      # Took 2 seconds on Macbook Pro 2.8 Ghz quad core
      dummy_values = ["0" * PREFIX_LENGTH * 2] * 1000000
      dummy_values.each_with_index do |_, i|
        dummy_values[i] = ("%8.8s" % i.to_s(16)).gsub(" ", "0")
      end
      result.concat(dummy_values)
    end

    to_protobuf_file(result)
  end

  def save_differential_file!(date:)
    result = SiteBannerLookup.find_by_sql(["
        SELECT SUBSTRING(sha2_base16, 1, :nibble_length)
        FROM site_banner_lookups
        WHERE to_char(\"created_at\", 'YYYY-MM-DD') = :date",
        {
          nibble_length: PREFIX_LENGTH * 2,
          date: date
        }
    ]).map { |r| r['substring'] }.uniq.sort!

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
    publisher_list_pb = PublishersPb::PublisherPrefixList.new
    publisher_list_pb.compression_type = @compression_type
    if @compression_type == PublishersPb::PublisherPrefixList::CompressionType::NO_COMPRESSION
      publisher_list_pb.prefixes = result.map { |item| [item].pack('H*') }.join("")
      publisher_list_pb.uncompressed_size = publisher_list_pb.prefixes.length
    elsif @compression_type == PublishersPb::PublisherPrefixList::CompressionType::BROTLI_COMPRESSION
      new_result = result.map { |item| [item].pack('H*') }.join("")
      publisher_list_pb.prefixes = Brotli.deflate(new_result)
      publisher_list_pb.uncompressed_size = new_result.length
    end
    publisher_list_pb.prefix_size = PREFIX_LENGTH
    temp_file = Tempfile.new.binmode
    temp_file.write(PublishersPb::PublisherPrefixList.encode(publisher_list_pb))
    temp_file.close
    temp_file
  end
end
