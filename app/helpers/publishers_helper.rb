module PublishersHelper
  def publisher_can_claim_funds?(publisher)
    # TODO: Also docusign ok
    publisher.bitcoin_address.present?
  end

  def publisher_can_generate_dns_record?(publisher)
    PublisherDnsRecordGenerator.new(publisher).can_perform?
  end

  def publisher_humanize_verified(publisher)
    if publisher.verified?
      I18n.t("publishers.verified")
    else
      I18n.t("publishers.not_verified")
    end
  end

  def publisher_verification_file_content(publisher)
    PublisherVerificationFileGenerator.new(publisher).generate_file_content
  end

  def publisher_verification_file_url(publisher)
    PublisherVerificationFileGenerator.new(publisher).generate_url
  end

  def publisher_next_step_path(publisher)
    if publisher.verified?
      home_publishers_path
    else
      verification_publishers_path
    end
  end

  # NOTE: Be careful! This link logs the publisher a back in.
  def publisher_private_reauth_url(publisher)
    publisher_url(publisher, token: publisher.authentication_token)
  end

  def publisher_verification_dns_record(publisher)
    PublisherDnsRecordGenerator.new(publisher).perform
  end
end
