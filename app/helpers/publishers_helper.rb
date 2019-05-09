module PublishersHelper
  include ChannelsHelper

  def sentry_catcher
    yield
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
  end

  def publishers_meta_tags
    {
      title: t("shared.app_title"),
      charset: "utf-8",
      og: {
        title: :title,
        image: image_url("open-graph-preview.png", host: root_url),
        description: t("shared.app_description"),
        url: request.url,
        type: "website"
      }
    }
  end

  def publisher_can_receive_funds?(publisher)
    publisher.uphold_connection&.uphold_status == :verified
  end

  def payout_in_progress?
    !!Rails.cache.fetch('payout_in_progress')
  end

  def next_deposit_date(today = DateTime.now)
    today = today + 1.month if today.day > 8
    today.strftime("%B 8th")
  end

  def publisher_overall_bat_balance(publisher)
    balance = I18n.t("helpers.publisher.balance_unavailable")
    sentry_catcher do
      publisher = publisher.become_subclass
      amount = publisher.wallet&.overall_balance&.amount_bat
      amount = publisher.balance if publisher.partner?
      balance = '%.2f' % amount if amount.present?
    end

    balance
  end

  def publisher_converted_overall_balance(publisher)
    return if publisher.default_currency == "BAT" || publisher.default_currency.blank?

    publisher = publisher&.become_subclass
    balance = publisher.wallet&.overall_balance&.amount_default_currency
    balance = publisher.balance_in_currency if publisher.partner?

    if balance.present?
      I18n.t("helpers.publisher.balance_pending_approximate",
             amount: '%.2f' % balance,
             code: publisher.default_currency)
    else
      I18n.t("helpers.publisher.conversion_unavailable", code: publisher.default_currency)
    end
  end

  def publisher_channel_bat_balance(publisher, channel_identifier)
    balance = I18n.t("helpers.publisher.balance_unavailable")
    sentry_catcher do
      channel_balance = publisher.wallet&.channel_balances&.dig(channel_identifier)
      balance = '%.2f' % channel_balance.amount_bat if channel_balance&.amount_bat.present?
    end

    balance
  end

  def publisher_last_settlement_bat_balance(publisher)
    last_settlement_balance = publisher.wallet&.last_settlement_balance
    if last_settlement_balance&.amount_bat.present?
      '%.2f' % last_settlement_balance.amount_bat
    else
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.balance_unavailable")
  end

  def publisher_converted_last_settlement_balance(publisher)
    last_settlement_balance = publisher.wallet&.last_settlement_balance

    if last_settlement_balance&.amount_settlement_currency.present?
      settlement_currency = last_settlement_balance.settlement_currency
      return if settlement_currency == "BAT"
      I18n.t("helpers.publisher.balance_pending_approximate",
             amount: '%.2f' % last_settlement_balance.amount_settlement_currency,
             code: settlement_currency)
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.conversion_unavailable", code: settlement_currency)
  end

  def publisher_last_settlement_date(publisher)
    last_settlement_balance = publisher.wallet&.last_settlement_balance
    if last_settlement_balance&.timestamp.present?
      Time.at(last_settlement_balance.timestamp).to_datetime.strftime("%B %d, %Y")
    else
      I18n.t("helpers.publisher.no_deposit")
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.no_deposit")
  end

  def publisher_uri(publisher)
    "https://#{publisher.brave_publisher_id}"
  end

  # def link_to_brave_publisher_id(publisher)
  #   uri = URI::HTTP.build(host: publisher.brave_publisher_id)
  #   link_to(publisher.brave_publisher_id, uri.to_s)
  # end

  def uphold_authorization_endpoint(publisher)
    # TODO: This method should be a PATCH route in an Uphold controller.
    # We should not be updating database values on GET requests
    publisher.uphold_connection&.prepare_uphold_state_token

    Rails.application.secrets[:uphold_authorization_endpoint]
        .gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_client_id])
        .gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope])
        .gsub('<STATE>', publisher.uphold_connection&.uphold_state_token)
  end

  def uphold_authorization_description(publisher)
    case publisher.uphold_connection&.uphold_status
    when :unconnected, nil
      I18n.t("helpers.publisher.uphold_authorization_description.connect_to_uphold")
    when UpholdConnection::UpholdAccountState::RESTRICTED
      publisher.wallet.is_a_member? ? I18n.t("helpers.publisher.uphold_authorization_description.visit_uphold_support") : I18n.t("helpers.publisher.uphold_authorization_description.visit_uphold_dashboard")
    else
      I18n.t("helpers.publisher.uphold_authorization_description.reconnect_to_uphold")
    end
  end

  def uphold_dashboard_url
    Rails.application.secrets[:uphold_dashboard_url]
  end

  def terms_of_service_url
    Rails.application.secrets[:terms_of_service_url]
  end

  def possible_currencies(publisher)
    publisher.wallet.present? ? publisher.wallet.possible_currencies : []
  end

  def uphold_status_class(publisher)
    case publisher.uphold_connection&.uphold_status
    when :verified, UpholdConnection::UpholdAccountState::BLOCKED
      # (Albert Wang): We notify Brave when we detect a login of someone with a blocked
      # Uphold account
      'uphold-complete'
    when :code_acquired, :access_parameters_acquired
      'uphold-processing'
    when :reauthorization_needed
      'uphold-reauthorization-needed'
    when UpholdConnection::UpholdAccountState::RESTRICTED
      'uphold-' + UpholdConnection::UpholdAccountState::RESTRICTED.to_s
    else
      'uphold-unconnected'
    end
  end

  def last_settlement_class(publisher)
    if publisher.wallet.present? &&
       publisher.wallet.last_settlement_balance &&
       publisher.wallet.last_settlement_balance.amount_bat.present?

      'settlement-made'
    else
      'no-settlement-made'
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
      publisher.wallet.is_a_member? ? I18n.t("helpers.publisher.uphold_status_description.restricted_member") : I18n.t("helpers.publisher.uphold_status_description.non_member")
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
      when "wordpress"
        verification_wordpress_publishers_path
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
    #     when "wordpress"
    #       verification_wordpress_publishers_path
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
    options = { token: token }
    options[:confirm_email] = confirm_email if (confirm_email)
    publisher_url(publisher, options)
  end

  def publisher_private_two_factor_removal_url(publisher:, confirm_email: nil)
    token = publisher.authentication_token
    options = { id: publisher.id, token: token }
    options[:confirm_email] = confirm_email if (confirm_email)
    confirm_two_factor_authentication_removal_publishers_url(nil, options)
  end

  def publisher_private_two_factor_cancellation_url(publisher:, confirm_email: nil)
    token = publisher.authentication_token
    options = { id: publisher.id, token: token }
    options[:confirm_email] = confirm_email if (confirm_email)
    cancel_two_factor_authentication_removal_publishers_url(nil, options)
  end

  def publisher_verification_dns_record(publisher)
    PublisherDnsRecordGenerator.new(publisher: publisher).perform
  end

  def publisher_statement_period(transactions)
    return "" if transactions.empty?
    statement_begin_date = "#{transactions.first["created_at"].to_time.strftime("%Y-%m-%d")}"
    statement_end_date = "#{transactions.last["created_at"].to_time.strftime("%Y-%m-%d")}"
    statement_period = statement_begin_date == statement_end_date ? statement_begin_date : "#{statement_begin_date} - #{statement_end_date}"
    statement_period
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

    email.split("@")[0].try(:capitalize)
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
    !Rails.application.secrets[:hide_faqs] && FaqCategory.ready_for_display.count > 0
  end

  def channel_type(channel)
    case channel.details
    when SiteChannelDetails
      I18n.t("helpers.publisher.channel_type.website")
    when YoutubeChannelDetails
      I18n.t("helpers.publisher.channel_type.youtube")
    when TwitchChannelDetails
      I18n.t("helpers.publisher.channel_type.twitch")
    when TwitterChannelDetails
      I18n.t("helpers.publisher.channel_type.twitter")
    else
      I18n.t("helpers.publisher.channel_type.unknown")
    end
  end

  def channel_name(channel)
    case channel.details
    when SiteChannelDetails
      I18n.t("helpers.publisher.channel_name.website")
    when YoutubeChannelDetails
      I18n.t("helpers.publisher.channel_name.youtube")
    when TwitchChannelDetails
      I18n.t("helpers.publisher.channel_name.twitch")
    else
      I18n.t("helpers.publisher.channel_name.unknown")
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
    case channel.details
      when SiteChannelDetails
        link_to(home_publishers_path)

      when YoutubeChannelDetails

      else
        link_to(home_publishers_path)
    end
  end

  def channel_type_icon_url(channel)
    case channel&.details
    when YoutubeChannelDetails
      asset_url('publishers-home/youtube-icon_32x32.png')
    when TwitchChannelDetails
      asset_url('publishers-home/twitch-icon_32x32.png')
    when TwitterChannelDetails
      asset_url('publishers-home/twitter-icon_32x32.png')
    else
      asset_url('publishers-home/website-icon_32x32.png')
    end
  end

  def channel_thumbnail_url(channel)
    url = case channel.details
          when YoutubeChannelDetails
            channel.details.thumbnail_url
          when TwitchChannelDetails
            channel.details.thumbnail_url
          when TwitterChannelDetails
            channel.details.thumbnail_url
          end

    return url || asset_url('default-channel.png')
  end

  def publisher_id_from_owner_identifier(owner_identifier)
    owner_identifier[/publishers#uuid:(.*)/,1]
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
