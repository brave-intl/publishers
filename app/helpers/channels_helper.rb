module ChannelsHelper

  def current_channel
    @current_channel
  end

  def site_last_verification_method_path(channel)
    case channel.details.verification_method
      when "dns_record"
        verification_dns_record_site_channel_path(channel)
      when "public_file"
        verification_public_file_site_channel_path(channel)
      when "github"
        verification_github_site_channel_path(channel)
      when "wordpress"
        verification_wordpress_site_channel_path(channel)
      when "support_queue"
        verification_support_queue_site_channel_path(channel)
      else
        verification_choose_method_site_channel_path(channel)
    end
  end

  def site_channel_next_step_path(channel)
    if channel.verified?
      home_publishers_path
    elsif channel.details.verification_method
      site_last_verification_method_path(channel)
    else
      case channel.details.detected_web_host
        when "wordpress"
          verification_wordpress_site_channel_path(channel)
        when "github"
          verification_github_site_channel_path(channel)
        else
          verification_choose_method_site_channel_path(channel)
      end
    end
  end

  def youtube_channel_next_step_path(channel)
    home_publishers_path
  end

  def channel_next_step_path(channel)
    case channel.details
      when SiteChannelDetails
        site_channel_next_step_path(channel)
      when YoutubeChannelDetails
        youtube_channel_next_step_path(channel)
      else
        home_publishers_path(channel.publisher)
    end
  end

  def channel_verification_status(channel)
    if channel.verified?
      'verified'
    elsif channel.verification_status.present?
      channel.verification_status
    else
      'incomplete'
    end
  end

  def channel_verification_details(channel)
    if channel.verification_failed?
      channel.verification_details || t("helpers.channels.generic_verification_failure")
    elsif channel.verification_started?
      t("helpers.channels.verification_in_progress")
    end
  end
end
