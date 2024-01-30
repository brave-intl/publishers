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

  def payout_in_progress?(publisher)
    selected_wallet = publisher.selected_wallet_provider
    payouts_in_progress = Rails.cache.fetch(SetPayoutsInProgressJob::PAYOUTS_IN_PROGRESS)
    selected_wallet.present? && payouts_in_progress.present? && payouts_in_progress[publisher.selected_wallet_provider.class.name.underscore]
  end

  def next_deposit_date(today: DateTime.now)
    today += 1.month if today.day > 13
    today.strftime("%B 13th")
  end

  def has_balance?(publisher)
    publisher.wallet&.contribution_balance&.channel_amounts_usd&.each do |channel_amount_usd|
      return true if channel_amount_usd >= PENNY
    end

    referral_balance = publisher.wallet&.referral_balance&.amount_usd
    referral_balance && referral_balance >= PENNY
  end

  def publisher_overall_bat_balance_amount(publisher)
    amount = 0.0
    error_catcher do
      amount = if publisher.only_user_funds?
        publisher.wallet&.contribution_balance&.amount_bat
      elsif publisher.no_grants?
        (publisher.wallet&.overall_balance&.amount_bat || 0) - (publisher.wallet&.contribution_balance&.amount_bat || 0)
      else
        publisher.wallet&.overall_balance&.amount_bat
      end
    end
    amount
  end

  def publisher_overall_bat_balance(publisher)
    balance = I18n.t("helpers.publisher.balance_unavailable")
    amount = [publisher_overall_bat_balance_amount(publisher), 0].compact.max
    balance = "%.2f" % amount if amount.present?
    balance
  end

  def publisher_converted_overall_balance(publisher)
    default_currency = publisher.selected_wallet_provider&.default_currency
    return if default_currency.blank?

    result = I18n.t("helpers.publisher.conversion_unavailable", code: default_currency)
    error_catcher do
      balance = if publisher.only_user_funds?
        publisher.wallet&.contribution_balance&.amount_default_currency
      elsif publisher.no_grants?
        (publisher.wallet&.overall_balance&.amount_default_currency || 0) - (publisher.wallet&.contribution_balance&.amount_default_currency || 0)
      else
        publisher.wallet&.overall_balance&.amount_default_currency
      end

      balance = [balance, 0].max

      if balance.present?
        result = I18n.t(
          "helpers.publisher.balance_pending_approximate",
          amount: "%.2f" % balance,
          code: default_currency
        )
      end
    end
    result
  end

  def publisher_referral_bat_balance(publisher)
    balance = I18n.t("helpers.publisher.balance_unavailable")
    error_catcher do
      amount = publisher.wallet&.referral_balance&.amount_bat
      balance = "%.2f" % amount if amount.present?
    end

    balance
  end

  def publisher_contribution_bat_balance(publisher)
    balance = I18n.t("helpers.publisher.balance_unavailable")
    error_catcher do
      amount = publisher.wallet&.contribution_balance&.amount_bat
      balance = "%.2f" % amount if amount.present?
    end

    balance
  end

  def publisher_channel_bat_balance(publisher, channel_identifier)
    balance = I18n.t("helpers.publisher.balance_unavailable")

    # Note: error catcher swallows important information
    error_catcher do
      channel_balance = publisher.wallet&.channel_balances&.dig(channel_identifier)
      value = (channel_balance.present? && channel_balance&.amount_bat.present?) ? channel_balance&.amount_bat : nil

      if value.present?
        temp = (value < 0) ? 0.0 : value
        balance = "%.2f" % temp
      end
    end

    balance
  end

  def publisher_bat_percent(publisher)
    contribution = publisher.wallet&.contribution_balance&.amount_bat
    referrals = publisher.wallet&.referral_balance&.amount_bat
    total = contribution + referrals
    {
      contribution: number_to_percentage(contribution / total * 100, precision: 1),
      referrals: number_to_percentage(referrals / total * 100, precision: 1)
    }
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
    if Rails.configuration.pub_secrets[:next_proxy_url] && Rails.configuration.pub_secrets[:next_proxy_enabled]
      options[:host] = Rails.configuration.pub_secrets[:next_proxy_url]
      options[:port] = Rails.configuration.pub_secrets[:next_proxy_port] if Rails.configuration.pub_secrets[:next_proxy_port].present?
    end
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
