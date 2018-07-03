module PublishersHelper
  include ChannelsHelper

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
    publisher.uphold_status == :verified
  end

  def publisher_humanize_balance(publisher, currency)
    if balance = publisher.wallet &&
        publisher.wallet.contribution_balance.is_a?(Eyeshade::Balance) &&
        publisher.wallet.contribution_balance
      '%.2f' % balance.convert_to(currency)
    else
      I18n.t("helpers.publisher.conversion_unavailable", code: currency)
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.conversion_unavailable", code: currency)
  end

  def next_deposit_date(today = DateTime.now)
    if today.day > 8
      today = today + 1.month
    end
    today.strftime("%B 8th")
  end

  def publisher_converted_balance(publisher)
    currency = publisher.default_currency
    return if currency == "BAT" || currency.blank?
    if balance = publisher.wallet &&
        publisher.wallet.contribution_balance.is_a?(Eyeshade::Balance) &&
        publisher.wallet.contribution_balance
      converted_amount = '%.2f' % balance.convert_to(currency)
      I18n.t("helpers.publisher.balance_pending_approximate", amount: converted_amount, code: currency)
    else
      I18n.t("helpers.publisher.conversion_unavailable", code: currency)
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.conversion_unavailable", code: currency)
  end

  def publisher_humanize_last_settlement(publisher, currency)
    if balance = publisher.wallet &&
        publisher.wallet.last_settlement_balance.is_a?(Eyeshade::Balance) &&
        publisher.wallet.last_settlement_balance
      '%.2f' % balance.convert_to(currency)
    else
      I18n.t("helpers.publisher.no_deposit")
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.conversion_unavailable", code: currency)
  end

  def publisher_converted_last_settlement(publisher)
    currency = publisher.default_currency
    return if currency == "BAT" || currency.blank?
    if balance = publisher.wallet &&
        publisher.wallet.last_settlement_balance.is_a?(Eyeshade::Balance) &&
        publisher.wallet.last_settlement_balance
      converted_amount = '%.2f' % balance.convert_to(currency)
      I18n.t("helpers.publisher.balance_pending_approximate", amount: converted_amount, code: currency)
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.conversion_unavailable", code: currency)
  end

  def publisher_humanize_last_settlement_date(publisher)
    if settlement_date = publisher.wallet &&
        publisher.wallet.last_settlement_date.is_a?(Date) &&
        publisher.wallet.last_settlement_date
      settlement_date.strftime("%B %d, %Y")
    else
      I18n.t("helpers.publisher.no_deposit")
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.no_deposit")
  end

  def publisher_channel_balance(publisher, channel_identifier, currency)
    if balance = (
        publisher.wallet &&
        publisher.wallet.channel_balances &&
        publisher.wallet.channel_balances[channel_identifier]
    )
      '%.2f' % balance.convert_to(currency)
    else
      I18n.t("helpers.publisher.conversion_unavailable", code: currency)
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.conversion_unavailable", code: currency)
  end

  def publisher_uri(publisher)
    "https://#{publisher.brave_publisher_id}"
  end

  # def link_to_brave_publisher_id(publisher)
  #   uri = URI::HTTP.build(host: publisher.brave_publisher_id)
  #   link_to(publisher.brave_publisher_id, uri.to_s)
  # end

  def uphold_authorization_endpoint(publisher)
    publisher.prepare_uphold_state_token

    Rails.application.secrets[:uphold_authorization_endpoint]
        .gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_client_id])
        .gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope])
        .gsub('<STATE>', publisher.uphold_state_token.to_s)
  end

  def uphold_authorization_description(publisher)
    case publisher.uphold_status
    when :unconnected
      I18n.t("helpers.publisher.uphold_authorization_description.connect_to_uphold")
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
    case publisher.uphold_status
    when :verified
      'uphold-complete'
    when :code_acquired, :access_parameters_acquired
      'uphold-processing'
    when :reauthorization_needed
      'uphold-reauthorization-needed'
    when :incomplete
      'uphold-incomplete'
    else
      'uphold-unconnected'
    end
  end

  def last_settlement_class(publisher)
    if publisher.wallet.present? && publisher.wallet.last_settlement_date
      'settlement-made'
    else
      'no-settlement-made'
    end
  end

  def uphold_status_summary(publisher)
    case publisher.uphold_status
    when :verified
      I18n.t("helpers.publisher.uphold_status_summary.connected")
    when :code_acquired, :access_parameters_acquired
      I18n.t("helpers.publisher.uphold_status_summary.connecting")
    when :reauthorization_needed
      I18n.t("helpers.publisher.uphold_status_summary.connection_problems")
    when :incomplete
      I18n.t("helpers.publisher.uphold_status_summary.incomplete")
    else
      I18n.t("helpers.publisher.uphold_status_summary.unconnected")
    end
  end

  def uphold_status_description(publisher)
    case publisher.uphold_status
    when :verified
      I18n.t("helpers.publisher.uphold_status_description.verified")
    when :code_acquired, :access_parameters_acquired
      I18n.t("helpers.publisher.uphold_status_description.connecting")
    when :reauthorization_needed
      I18n.t("helpers.publisher.uphold_status_description.reauthorization_needed")
    when :incomplete
      I18n.t("helpers.publisher.uphold_status_description.incomplete")
    when :unconnected
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
      when "support_queue"
        verification_support_queue_publishers_path
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

  def publisher_verification_dns_record(publisher)
    PublisherDnsRecordGenerator.new(publisher: publisher).perform
  end

  def all_statement_periods
    [:past_7_days,
     :past_30_days,
     :this_month,
     :last_month,
     :this_year,
     :last_year,
     :all]
  end

  def unused_statement_periods
    periods = all_statement_periods
    current_publisher.statements.visible_statements.each do |s|
      periods.delete(s.period.to_sym)
    end
    periods
  end

  def statement_periods_as_options(periods)
    periods.collect do |period|
      [statement_period_description(period), period]
    end
  end

  def statement_period_description(period)
    I18n.t("helpers.publisher.statement_periods.#{period}")
  end

  def statement_period_date(date)
    date.strftime('%b %e')
  end

  def link_to_most_recent_statement
    most_recent_statement = current_publisher.statements.order(created_at: :desc).first
    if most_recent_statement.present?
      statement_name = t("publishers.home.statements.statement_name",
                         created_at: statement_period_date(most_recent_statement.created_at),
                         period: statement_period_description(most_recent_statement.period))

      t("publishers.home.statements.view_recent_statement",
        statement_link: link_to(statement_name, statements_publishers_path)).html_safe
    else
      (t("publishers.statements.description") +
        '<br/>' +
        link_to(t(".statements.view_statements"), statements_publishers_path)).html_safe
    end
  end

  def publisher_statement_filename(publisher_statement)
    publisher_id = publisher_statement.publisher.name
    date = publisher_statement.created_at.to_date.iso8601
    period = publisher_statement.period.to_s.gsub('_', '-')

    "#{publisher_id}-#{date}-#{period}.csv"
  end

  def link_to_publisher_statement(publisher_statement)
    link_to(publisher_statement_filename(publisher_statement), statement_publishers_url(id: publisher_statement.id))
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
    case channel.details
    when YoutubeChannelDetails
      asset_url('publishers-home/youtube-icon_32x32.png')
    when TwitchChannelDetails
      asset_url('publishers-home/twitch-icon_32x32.png')
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
