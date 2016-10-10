module PublisherLegalFormHelper
  def publisher_legal_form_humanize_form_type(legal_form)
    return nil if legal_form.form_type.nil?
    case legal_form.form_type
    when "irs_w_8ben"
      "IRS W-8BEN"
    when "irs_w_8ben_e"
      "IRS W-8BEN-E"
    when "irs_w_9"
      "IRS W-9"
    else
      legal_form.form_type.humanize
    end
  end

  # Statuses:
  # https://docs.docusign.com/esign/restapi/Envelopes/Envelopes/listStatusChanges/
  def publisher_legal_form_humanize_status(legal_form)
    return nil if legal_form.status.nil?
    legal_form.status.humanize
  end
end
