module SiteChannelsHelper
  include ChannelsHelper

  def site_channel_filtered_verification_token(channel)
    if channel.details.supports_https?
      channel.details.verification_token
    else
      # ToDo: Do we want to display a fake token? Will show up in disabled forms
      ""
    end
  end

  def site_channel_filter_public_file_content(channel, file_content)
    if channel.details.supports_https?
      file_content
    else
      # ToDo: Do we want to display a fake token? Will show up in disabled forms
      ""
    end
  end

  def site_channel_verification_dns_record(channel)
    SiteChannelDnsRecordGenerator.new(channel: channel).perform
  end

  def should_open_verification_failed_modal?(channel, current_method)
    current_channel.verification_failed? && current_channel.details.verification_method == current_method
  end
end
