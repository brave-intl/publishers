module PublishersHelper
  def publisher_can_receive_funds?(publisher)
    publisher.uphold_status == :verified
  end

  def uphold_status_description(publisher)
    case publisher.uphold_status
    when :verified
      t("publishers.uphold_status_verified")
    when :access_parameters_acquired
      t("publishers.uphold_status_access_parameters_acquired")
    when :code_acquired
      t("publishers.uphold_status_code_acquired")
    when :unconnected
      t("publishers.uphold_status_unconnected")
    end
  end

  def show_uphold_connect?(publisher)
    publisher.uphold_status == :unconnected || publisher.uphold_status == :code_acquired
  end

  def poll_uphold_status?(publisher)
    publisher.uphold_status == :access_parameters_acquired
  end

  # balance: Instance of Eyeshade::Balance
  def publisher_humanize_balance(publisher)
    if balance = publisher.balance
      "#{'%.2f' % balance.BAT} BAT (#{'%.2f' % balance.convert_to('USD')} USD)"
    else
      I18n.t("publishers.balance_error")
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("publishers.balance_error")
  end

  # FIXME: To be removed once BAT transition is complete.
  def publisher_humanize_legacy_balance(publisher)
    if balance = publisher.legacy_balance
      number_to_currency(balance.amount)
    else
      I18n.t("publishers.balance_error")
    end
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    I18n.t("publishers.balance_error")
  end

  def publisher_legacy_balance?(publisher)
    publisher.legacy_balance && publisher.legacy_balance.amount.to_i && publisher.legacy_balance.amount.to_i > 0
  end

  def publisher_uri(publisher)
    "https://#{publisher.brave_publisher_id}"
  end

  def link_to_brave_publisher_id(publisher)
    uri = URI::HTTP.build(host: publisher.brave_publisher_id)
    link_to(publisher.brave_publisher_id, uri.to_s)
  end

  def uphold_authorization_endpoint(publisher)
    publisher.prepare_uphold_state_token

    Rails.application.secrets[:uphold_authorization_endpoint]
        .gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_client_id])
        .gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope])
        .gsub('<STATE>', publisher.uphold_state_token.to_s)
  end

  def publisher_humanize_verified(publisher)
    if publisher.verified?
      I18n.t("publishers.verified")
    else
      I18n.t("publishers.not_verified")
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

  def publisher_status(publisher)
    if publisher.verified?
      if publisher.uphold_complete?
        :complete
      elsif publisher.uphold_status == :code_acquired
        :uphold_processing
      else
        :uphold_unconnected
      end
    else
      :unverified
    end
  end

  def publisher_status_description(publisher)
    case publisher_status(publisher)
    when :complete
      t("publishers.status_complete")
    when :uphold_processing
      t("publishers.status_uphold_processing")
    when :uphold_unconnected
      t("publishers.status_uphold_unconnected")
    when :unverified
      t("publishers.status_unverified")
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
    if publisher.verified?
      home_publishers_path
    elsif publisher.brave_publisher_id.blank?
      email_verified_publishers_path
    else
      case publisher.detected_web_host
        when "wordpress"
          verification_wordpress_publishers_path
        when "github"
          verification_github_publishers_path
        else
          verification_choose_method_publishers_path
      end
    end
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

  def publisher_statement_periods
    [
      [t('publisher_statement_periods.past_7_days'), :past_7_days],
      [t('publisher_statement_periods.past_30_days'), :past_30_days],
      [t('publisher_statement_periods.this_month'), :this_month],
      [t('publisher_statement_periods.last_month'), :last_month],
      [t('publisher_statement_periods.this_year'), :this_year],
      [t('publisher_statement_periods.last_year'), :last_year],
      [t('publisher_statement_periods.all'), :all]
    ]
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
end
