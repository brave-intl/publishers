# typed: ignore

module PublishersHelper
  include ChannelsHelper

  PENNY = 0.01

  def error_catcher
    yield
  rescue => e
    LogException.perform(e)
  end

  def publishers_meta_tags
    {
      title: t("shared.app_title"),
      charset: "utf-8",
      og: {
        title: :title,
        image: image_url("open-graph-preview.png"),
        description: t("shared.app_description"),
        url: request.url,
        type: "website"
      }
    }
  end

  def public_meta_tags
    {
      title: t("shared.public_page_title"),
      charset: "utf-8",
      og: {
        title: t("shared.public_share_title"),
        image: image_url("open-graph-preview.png"),
        description: t("shared.public_share_description", channel: @channel_title),
        url: request.url,
        type: "website"
      }
    }
  end

  def new_publisher?(publisher)
    is_new = if publisher.bitflyer_locale?(I18n.locale)
      publisher.bitflyer_connection.blank?
    else
      publisher.uphold_connection&.unconnected? && publisher.gemini_connection.blank?
    end
    is_new.present? && publisher.channels.size.zero?
  end

  def uphold_dashboard_url
    Rails.configuration.pub_secrets[:uphold_dashboard_url]
  end

  def terms_of_service_url
    Rails.configuration.pub_secrets[:terms_of_service_url]
  end

  def uphold_status_class(publisher)
    case publisher.uphold_connection&.uphold_status
    when :verified, UpholdConnection::UpholdAccountState::BLOCKED
      # (Albert Wang): We notify Brave when we detect a login of someone with a blocked
      # Uphold account
      "uphold-complete"
    when :code_acquired, :access_parameters_acquired
      "uphold-processing"
    when :reauthorization_needed
      "uphold-reauthorization-needed"
    when UpholdConnection::UpholdAccountState::RESTRICTED
      "uphold-" + UpholdConnection::UpholdAccountState::RESTRICTED.to_s
    else
      "uphold-unconnected"
    end
  end

  def uphold_status_summary(publisher)
    case publisher.uphold_connection&.uphold_status
    when :verified, UpholdConnection::UpholdAccountState::RESTRICTED, UpholdConnection::UpholdAccountState::BLOCKED
      I18n.t("helpers.publisher.uphold_status_summary.connected")
    when :code_acquired, :access_parameters_acquired
      I18n.t("helpers.publisher.uphold_status_summary.connecting")
    when :reauthorization_needed
      I18n.t("helpers.publisher.uphold_status_summary.connection_problems")
    else
      I18n.t("helpers.publisher.uphold_status_summary.unconnected")
    end
  end

  def uphold_status_description(publisher)
    case publisher.uphold_connection&.uphold_status
    when :verified
      I18n.t("helpers.publisher.uphold_status_description.verified")
    when :code_acquired, :access_parameters_acquired
      I18n.t("helpers.publisher.uphold_status_description.connecting")
    when :reauthorization_needed
      I18n.t("helpers.publisher.uphold_status_description.reauthorization_needed")
    when :unconnected
      I18n.t("helpers.publisher.uphold_status_description.unconnected")
    when UpholdConnection::UpholdAccountState::RESTRICTED
      publisher.uphold_connection.is_member? ? I18n.t("helpers.publisher.uphold_status_description.restricted_member") : I18n.t("helpers.publisher.uphold_status_description.non_member")
    else
      I18n.t("helpers.publisher.uphold_status_description.unconnected")
    end
  end

  def publisher_last_verification_method_path(publisher)
    case publisher.verification_method
    when "dns_record"
      verification_dns_record_publishers_path
    when "public_file"
      verification_public_file_publishers_path
    when "github"
      verification_github_publishers_path
    else
      verification_choose_method_publishers_path
    end
  end

  def publisher_next_step_path(publisher)
    if session[:publisher_created_through_youtube_auth]
      change_email_confirm_publishers_path
    elsif publisher.verified?
      home_publishers_path
    elsif publisher.email_verified?
      email_verified_publishers_path
    end

    # elsif publisher.brave_publisher_id.blank?
    #   email_verified_publishers_path
    # else
    #   case publisher.detected_web_host
    #     when "github"
    #       verification_github_publishers_path
    #     else
    #       verification_choose_method_publishers_path
    #   end
    # end
  end

  # NOTE: Be careful! This link logs the publisher a back in.
  # This also no longer  automatically updates the token, which should now be handled by calling one of the
  # mailer services
  def publisher_private_reauth_url(publisher:, confirm_email: nil)
    token = publisher.authentication_token
    options = {token: token}
    options[:confirm_email] = confirm_email if confirm_email
    publisher_url(publisher, options)
  end

  def publisher_private_two_factor_removal_url(publisher:, confirm_email: nil)
    token = publisher.authentication_token
    options = {id: publisher.id, token: token}
    options[:confirm_email] = confirm_email if confirm_email
    confirm_two_factor_authentication_removal_publishers_url(nil, options)
  end

  def publisher_private_two_factor_cancellation_url(publisher:, confirm_email: nil)
    token = publisher.authentication_token
    options = {id: publisher.id, token: token}
    options[:confirm_email] = confirm_email if confirm_email
    cancel_two_factor_authentication_removal_publishers_url(nil, options)
  end

  def publisher_verification_dns_record(publisher)
    PublisherDnsRecordGenerator.new(publisher: publisher).perform
  end

  def publisher_statement_period(transactions)
    return "" if transactions.empty?
    statement_begin_date = transactions.first["created_at"].to_time.strftime("%Y-%m-%d").to_s
    statement_end_date = transactions.last["created_at"].to_time.strftime("%Y-%m-%d").to_s
    (statement_begin_date == statement_end_date) ? statement_begin_date : "#{statement_begin_date} - #{statement_end_date}"
  end

  def publishers_statement_file_name(publisher_statement_period)
    "#{t("publishers.statements.statement_file_name")}-#{publisher_statement_period}.html"
  end

  def publisher_filtered_verification_token(publisher)
    if publisher.supports_https?
      publisher.verification_token
    else
      # ToDo: Do we want to display a fake token? Will show up in disabled forms
      ""
    end
  end

  def publisher_filter_public_file_content(publisher, file_content)
    if publisher.supports_https?
      file_content
    else
      # ToDo: Do we want to display a fake token? Will show up in disabled forms
      ""
    end
  end

  def name_from_email(email)
    return "Publisher" unless email.is_a?(String)

    email
  end

  def two_factor_enabled?(publisher)
    totp_enabled?(publisher) || u2f_enabled?(publisher)
  end

  def totp_enabled?(publisher)
    publisher.totp_registration.present?
  end

  def u2f_enabled?(publisher)
    publisher.u2f_registrations.any?
  end

  def show_nav_menu?(publisher)
    publisher.verified?
  end

  def show_faq_link?
    !Rails.configuration.pub_secrets[:hide_faqs] && FaqCategory.ready_for_display.count > 0
  end

  def channel_type(channel)
    case channel.details
    when SiteChannelDetails
      I18n.t("helpers.publisher.channel_type.website")
    else
      I18n.t("helpers.publisher.channel_type.#{channel.type_display.downcase}")
    end
  end

  def channel_name(channel)
    case channel.details
    when SiteChannelDetails
      I18n.t("helpers.publisher.channel_name.website")
    else
      I18n.t("helpers.publisher.channel_name.#{channel.type_display.downcase}")
    end
  end

  def show_taken_channel_registration?(channel)
    case channel.details
    when YoutubeChannelDetails
      true
    else
      false
    end
  end

  def channel_edit_link(channel)
    link_to(home_publishers_path)
  end

  def channel_type_icon_url(channel)
    case channel&.details
    when SiteChannelDetails
      "publishers-home/website-icon_32x32.png"
    else
      "publishers-home/#{channel.type_display.downcase}-icon_32x32.png"
    end
  end

  def channel_thumbnail_url(channel)
    url = channel.details.thumbnail_url if channel.details.respond_to?(:thumbnail_url)

    url || asset_url("default-channel.png")
  end

  def publisher_id_from_owner_identifier(owner_identifier)
    owner_identifier[/publishers#uuid:(.*)/, 1]
  end

  def email_is_youtube_format?(email)
    /.+@pages\.plusgoogle\.com/.match(email)
  end

  def youtube_login_permitted?(channel)
    details = channel.details
    if details.is_a?(YoutubeChannelDetails)
      publisher = channel.publisher
      if details.auth_email == publisher.email
        if publisher.email
          return !email_is_youtube_format?(publisher.email).nil?
        end
      end
    end

    false
  end

  def publisher_created_through_youtube_auth?(publisher)
    publisher && publisher.channels.visible.count == 1 && youtube_login_permitted?(publisher.channels.visible.first)
  end
end
