module PublishersHelper
  def publisher_can_receive_funds?(publisher)
    publisher.legal_form_completed? && publisher.bitcoin_address.present?
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

  def uphold_authorization_endpoint(publisher)
    Rails.application.secrets[:uphold_authorization_endpoint]
        .gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_client_id])
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

  def publisher_next_step_path(publisher)
    return verification_publishers_path if !publisher.verified?
    # ToDo: Polling page for exchanging uphold_code for uphold_access_parameters
    # return authorize_uphold_path if publisher.uphold_code && publisher.uphold_access_parameters.blank?
    return verification_done_publishers_path if publisher.uphold_access_parameters.blank?

    home_publishers_path
  end

  # NOTE: Be careful! This link logs the publisher a back in.
  def generate_publisher_private_reauth_url(publisher)
    token = PublisherTokenGenerator.new(publisher: publisher).perform
    publisher_url(publisher, token: token)
  end

  def publisher_verification_dns_record(publisher)
    PublisherDnsRecordGenerator.new(publisher: publisher).perform
  end
end
