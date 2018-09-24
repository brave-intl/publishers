module ChannelsHelper
  include ActionView::Helpers::DateHelper

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
    return if channel.verified? || channel.details_type != "SiteChannelDetails"
    case channel.verification_details
      when "domain_not_found"
        I18n.t("helpers.channels.verification_failure_explanation.domain_not_found")
      when "connection_failed"
        I18n.t("helpers.channels.verification_failure_explanation.connection_failed", domain: channel.details.brave_publisher_id)
      when "too_many_redirects"
        I18n.t("helpers.channels.verification_failure_explanation.too_many_redirects")
      when "no_txt_records"
        I18n.t("helpers.channels.verification_failure_explanation.no_txt_records")
      when "token_incorrect_dns"
        I18n.t("helpers.channels.verification_failure_explanation.token_incorrect_dns")
      when "token_not_found_dns"
        I18n.t("helpers.channels.verification_failure_explanation.token_not_found_dns")
      when "token_not_found_public_file"
        I18n.t("helpers.channels.verification_failure_explanation.token_not_found_public_file")
      when "no_https"
        I18n.t("helpers.channels.verification_failure_explanation.no_https")
      else
        I18n.t("helpers.channels.verification_failure_explanation.generic")
    end
  end

  def failed_verification_call_to_action(channel)
    return if channel.verified? || channel.details_type != "SiteChannelDetails"
    case channel.verification_details
      when "domain_not_found"
        I18n.t("helpers.channels.verification_failure_cta.domain_not_found")
      when "connection_failed"
        I18n.t("helpers.channels.verification_failure_cta.connection_failed")
      when "too_many_redirects"
        I18n.t("helpers.channels.verification_failure_cta.too_many_redirects")
      when "no_txt_records"
        I18n.t("helpers.channels.verification_failure_cta.no_txt_records")
      when "token_incorrect_dns"
        I18n.t("helpers.channels.verification_failure_cta.token_incorrect_dns")
      when "token_not_found_dns"
        I18n.t("helpers.channels.verification_failure_cta.token_not_found_dns")
      when "token_not_found_public_file"
        I18n.t("helpers.channels.verification_failure_cta.token_not_found_public_file_html", domain: channel.details.brave_publisher_id)
      when "no_https"
        I18n.t("helpers.channels.verification_failure_cta.no_https")
      else
        I18n.t("helpers.channels.verification_failure_cta.generic", support_email: Rails.application.secrets[:support_email])
    end
  end

  def should_display_verification_token?(channel)
    return false if channel.verified? || channel.details_type != "SiteChannelDetails"
    ["no_txt_records", "token_incorrect_dns", "token_not_found_dns"].include?(channel.verification_details)
  end

  def time_until_transfer(channel)
    return unless channel.verification_pending? || channel.contest_token.present?
    contest_timesout_at = channel.contest_timesout_at || channel.contesting_channel.contest_timesout_at
    contest_already_timed_out = (contest_timesout_at - Time.now) < 0

    if contest_already_timed_out
      I18n.t("shared.time_until_transfer_fallback")
    else
      distance_of_time_in_words(Time.now, channel.contesting_channel.contest_timesout_at)
    end
  end

  def get_channel_from_channel_id(channel_id)
    channel_id_split_on_prefix = channel_id.split(":", 2)
    channel_is_site_channel = channel_id_split_on_prefix.length == 1 # hack to identify site channels

    if channel_is_site_channel
      channel_details_type_identifier = channel_id_split_on_prefix.first
    else
      prefix = channel_id_split_on_prefix.first
      channel_details_type_identifier = channel_id_split_on_prefix.second
    end

    if channel_is_site_channel
      SiteChannelDetails.where(brave_publisher_id: channel_details_type_identifier).
                        joins(:channel).
                        where('channels.verified = true').first.channel
    else
      case prefix
        when "youtube#channel"
          YoutubeChannelDetails.where(youtube_channel_id: channel_details_type_identifier).
                                joins(:channel).
                                where('channels.verified = true').first.channel
        when "twitch#channel"
          TwitchChannelDetails.where(name: channel_details_type_identifier).
                              joins(:channel).
                              where('channels.verified = true').first.channel
        when "twitch#author"
          TwitchChannelDetails.where(name: channel_details_type_identifier).
                              joins(:channel).
                              where('channels.verified = true').first.channel
        when "twitter#channel"
          TwitterChannelDetails.where(twitter_channel_id: channel_details_type_identifier).
                               joins(:channel).
                               where('channels.verified = true').first.channel
        else 
          raise "Unable to find channel for channel identifier #{channel_id}"
      end
    end
  end
end
