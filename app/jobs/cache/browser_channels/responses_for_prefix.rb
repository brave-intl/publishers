class Cache::BrowserChannels::ResponsesForPrefix
  include Sidekiq::Worker

  PATH = "channels/prefix/"

  def perform(prefix:)
    site_banner_lookups = SiteBannerLookup.where("sha_base16 LIKE #{prefix}%")
    channel_responses = Publishers::Protos::ChannelResponses.new
    site_banner_lookups.each do |site_banner_lookup|
      channel_response = Publishers::Protos::ChannelResponse.new
      channel_response.channel_identifier = site_banner_lookup.channel_identifier
      channel_response.wallet_connected_state = site_banner_lookup.wallet_status
      channel_response.wallet_address = site_banner_lookup.wallet_address
      channel_response.site_banner_details = get_site_banner_details(site_banner_lookup)
      channel_responses.channel_response.push(channel_response)
    end

    json = ChannelResponses::ChannelResponses.encode_json(channel_responses)
    temp_file = Tempfile.new([prefix, ".br"])
    info = Brotli.deflate(json)
    File.open(temp_file.path, 'w') do |f|
      f.write(info)
    end

    require 'aws-sdk-s3'
    Aws.config[:credentials] = Aws::Credentials.new(Rails.application.secrets[:s3_rewards_access_key_id], Rails.application.secrets[:s3_rewards_secret_access_key])
    s3 = Aws::S3::Resource.new(region: Rails.application.secrets[:s3_rewards_bucket_region])
    obj = s3.bucket(Rails.application.secrets[:s3_rewards_bucket_name]).object(PATH + prefix)
    obj.upload_file(temp_file.path)
  end

  private

  def get_site_banner_details(site_banner_lookup)
    details = Publishers::Protos::SiteBannerDetails.new
    site_banner_details.derived_site_banner_info.keys.each do |k|
      details[k] = site_banner_details.derived_site_banner_info[k]
    end
    details
  end
end
