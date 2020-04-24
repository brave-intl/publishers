class Cache::BrowserChannels::ResponsesForPrefix
  include Sidekiq::Worker

  PATH = "channels/prefix/"

  def perform(prefix:)
    site_banner_lookups = SiteBannerLookup.where("sha2_base16 LIKE '#{prefix}%'")
    channel_responses = PublishersPb::ChannelResponses.new
    site_banner_lookups.each do |site_banner_lookup|
      channel_response = PublishersPb::ChannelResponse.new
      channel_response.channel_identifier = site_banner_lookup.channel_identifier
      channel_response.wallet_connected_state = site_banner_lookup.wallet_status
      channel_response.wallet_address = site_banner_lookup.wallet_address
      channel_response.site_banner_details = get_site_banner_details(site_banner_lookup)
      channel_responses.channel_response.push(channel_response)
    end

    json = PublishersPb::ChannelResponses.encode_json(channel_responses)
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
    details = PublishersPb::SiteBannerDetails.new
    site_banner_lookup.derived_site_banner_info.keys.each do |key|
      # Convert to snake_case
      value = site_banner_lookup.derived_site_banner_info[key]
      next if value.nil? || value.is_a?(Hash) || value.is_a?(Array)
      details[key.underscore] = value
    end

    if site_banner_lookup.derived_site_banner_info["donationAmounts"] != SiteBanner::DEFAULT_AMOUNTS
      # Confusing. This is the suggested implementation (no, normal assignment doesn't work)
      # https://github.com/protocolbuffers/protobuf/issues/320
      details.donation_amounts += site_banner_lookup.derived_site_banner_info["donationAmounts"]
    end

    social_links_pb = nil
    site_banner_lookup.derived_site_banner_info["socialLinks"].each do |domain, handle|
      if handle.present?
        social_links_pb = PublishersPb::SocialLinks.new if social_links_pb.nil?
        social_links_pb[domain] = handle
      end
    end
    details.social_links = social_links_pb if social_links_pb.present?
    details
  end
end
