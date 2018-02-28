module PublishersHelper
  include ChannelsHelper

  def publisher_can_receive_funds?(publisher)
    publisher.uphold_status == :verified
  end

  def uphold_status_description(publisher)
    case publisher.uphold_status
    when :verified
      I18n.t("helpers.publisher.uphold_status.verified")
    when :access_parameters_acquired
      I18n.t("helpers.publisher.uphold_status.access_parameters_acquired")
    when :code_acquired
      I18n.t("helpers.publisher.uphold_status.code_acquired")
    when :unconnected
      I18n.t("helpers.publisher.uphold_status.unconnected")
    end
  end

  def uphold_last_deposit_date(publisher)
    "September 31st, 2022 (ToDo)"
  end

  def show_uphold_connect?(publisher)
    publisher.uphold_status == :unconnected || publisher.uphold_status == :code_acquired || publisher.uphold_status == :access_parameters_acquired
  end

  def show_uphold_dashboard?(publisher)
    publisher.uphold_verified?
  end

  def uphold_status_class(publisher)
    "uphold-status-#{publisher.uphold_status.to_s.gsub('_', '-')}"
  end

  def publisher_humanize_balance(publisher, currency)
    if balance = publisher.wallet && publisher.wallet.contribution_balance
      '%.2f' % balance.convert_to(currency)
    else
      I18n.t("helpers.publisher.balance_error")
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.balance_error")
  end

  def publisher_converted_balance(publisher)
    currency = publisher_default_currency(publisher)
    return if currency == "BAT"
    if balance = publisher.wallet && publisher.wallet.contribution_balance
      converted_amount = '%.2f' % balance.convert_to(currency)
      I18n.t("helpers.publisher.balance_pending_approximate", amount: converted_amount, code: currency)
    else
      I18n.t("helpers.publisher.balance_error")
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("helpers.publisher.balance_error")
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
    if publisher_status(publisher) == :uphold_reauthorize || publisher_status(publisher) == :uphold_processing
      I18n.t("helpers.publisher.reconnect_to_uphold")
    else
      I18n.t("helpers.publisher.create_uphold_wallet")
    end
  end

  def uphold_dashboard_url
    Rails.application.secrets[:uphold_dashboard_url]
  end

  def terms_of_service_url
    Rails.application.secrets[:terms_of_service_url]
  end

  def publisher_default_currency(publisher)
    publisher.default_currency.present? ? publisher.default_currency : 'BAT'
  end

  def publisher_available_currencies(publisher)
    available_currencies = publisher.wallet.try(:wallet_details).try(:[], 'availableCurrencies')
    available_currencies.blank? ? ['BAT'] : available_currencies
  end

  def publisher_verification_status(publisher)
    publisher.verified? ? :verified : :unverified
  end

  def publisher_verification_status_description(publisher)
    case publisher_verification_status(publisher)
      when :verified
        I18n.t("publishers.shared.verified")
      when :unverified
        I18n.t("helpers.publisher.not_verified")
    end
  end

  def publisher_verification_file_content(publisher)
    PublisherVerificationFileGenerator.new(publisher: publisher).generate_file_content
  end

  def publisher_verification_file_directory(publisher)
    "<span class=\"strong-line\">https:</span>//#{publisher.brave_publisher_id}/.well-known/"
  end

  def publisher_verification_file_url(publisher)
    PublisherVerificationFileGenerator.new(publisher: publisher).generate_url
  end

  # Overall publisher status combining verification and uphold wallet connection
  def publisher_status(publisher)
    if publisher.verified?
      if publisher.uphold_verified?
        :complete
      elsif publisher.uphold_status == :code_acquired || publisher.uphold_status == :access_parameters_acquired
        :uphold_processing
      else
        if publisher.wallet.try(:status).try(:[], 'action') == 're-authorize'
          :uphold_reauthorize
        else
          :uphold_unconnected
        end
      end
    else
      :unverified
    end
  end

  def publisher_status_timeout(publisher)
    case publisher_status(publisher)
    when :uphold_processing
      I18n.t("helpers.publisher.uphold_status.processing_timeout")
    else
      nil
    end
  end

  def publisher_status_description(publisher)
    case publisher_status(publisher)
    when :complete
      I18n.t("helpers.publisher.uphold_status.balance_sending")
    when :uphold_processing
      I18n.t("helpers.publisher.uphold_status.processing")
    when :uphold_reauthorize
      I18n.t("helpers.publisher.uphold_status.reconnect_to_uphold")
    when :uphold_unconnected
      I18n.t("helpers.publisher.uphold_status.connect_to_uphold")
    when :unverified
      I18n.t("helpers.publisher.uphold_status.unverified")
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
  def generate_publisher_private_reauth_url(publisher, confirm_email = nil)
    token = PublisherTokenGenerator.new(publisher: publisher).perform
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
    current_publisher.statements.each do |s|
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
    date.strftime('%B %e, %Y')
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
