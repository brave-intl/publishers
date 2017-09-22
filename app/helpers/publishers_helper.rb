module PublishersHelper
  def publisher_can_receive_funds?(publisher)
    publisher.uphold_status == :verified
  end

  # balance: Instance of PublisherBalanceGetter::Balance
  def publisher_humanize_balance(publisher)
    if balance = publisher.balance
      number_to_currency(balance.amount)
    else
      I18n.t("publishers.balance_error")
    end
  end

  def publisher_uri(publisher)
    "https://#{publisher.brave_publisher_id}"
  end

  def link_to_brave_publisher_id(publisher)
    uri = URI::HTTP.build(host: publisher.brave_publisher_id)
    link_to(publisher.brave_publisher_id, uri.to_s)
  end

  def uphold_authorization_endpoint(publisher)
    Rails.application.secrets[:uphold_authorization_endpoint]
        .gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_client_id])
        .gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope])
        .gsub('<STATE>', publisher.uphold_state_token)
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
    if publisher.uphold_complete?
      :complete
    elsif publisher.brave_publisher_id.blank?
      :brave_publisher_id_needed
    elsif !publisher.verified?
      :unverified
    else
      :verified
    end
  end

  def publisher_next_step_path(publisher)
    case publisher_status(publisher)
      when :complete
        home_publishers_path
      when :brave_publisher_id_needed
        email_verified_publishers_path
      when :unverified
        case publisher.verification_method
          when "public_file"
            verification_public_file_publishers_path
          when "dns_record"
            verification_dns_record_publishers_path
          else
            verification_publishers_path
        end
      when :verified
        verification_done_publishers_path
    end

    # ToDo: Polling page for exchanging uphold_code for uphold_access_parameters
    # return authorize_uphold_path if publisher.uphold_code && publisher.uphold_access_parameters.blank?
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
end
