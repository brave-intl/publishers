class Cache::BrowserChannels::PrefixList
  include Sidekiq::Worker

  # Might need to adjust the value based on 
  PREFIX_LENGTH = 9
  ALL_CHANNELS_KEY = "all_channels"
  EXTENSION = ".br"

  def perform(details_type: nil)
    result = ActiveRecord::Base.connection.execute("SELECT SUBSTRING(sha2_base16, 1, #{PREFIX_LENGTH}) FROM site_banner_lookups").map { |r| r['substring'] }.to_json
    require 'brotli'
    temp_file = Tempfile.new(["all_channels", ".br"])
    info = Brotli.deflate(result)
    File.open(temp_file.path, 'wb') do |f|
      f.write(info)
    end
    require 'aws-sdk-s3'
    Aws.config[:credentials] = Aws::Credentials.new(Rails.application.secrets[:s3_rewards_access_key_id], Rails.application.secrets[:s3_rewards_secret_access_key])
    s3 = Aws::S3::Resource.new(region: Rails.application.secrets[:s3_rewards_bucket_region])
    obj = s3.bucket(Rails.application.secrets[:s3_rewards_bucket_name]).object(ALL_CHANNELS_KEY + EXTENSION)
    obj.upload_file(temp_file.path)
  end
end
