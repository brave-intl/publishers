class PartnerMailer < ApplicationMailer
  include PublishersHelper
  add_template_helper(PublishersHelper)

  after_action :ensure_fresh_token, only: [:invoice_file_added]

  def invoice_file_added(invoice_file, publisher)
    @invoice_file = invoice_file
    @publisher = publisher
    PublisherTokenGenerator.new(publisher: @publisher).perform

    @private_reauth_url = publisher_private_reauth_url(publisher: @publisher)

    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  def notify_bizdev_invoice_file_added(invoice_file)
    return if BIZDEV_EMAIL.blank?

    @invoice_file = invoice_file
    @invoice = invoice_file.invoice
    @publisher = invoice_file.uploaded_by
    @organization_name = @publisher.becomes(Partner).organization.name if @publisher.partner?

    mail(
      to: BIZDEV_EMAIL,
      subject: "#{@publisher} has added a new document to their #{@invoice.human_date} invoice"
    )
  end

  private

  def ensure_fresh_token
    # Check if we are missing the token and capture to sentry if we are. This should not happen.
    begin
      raise "missing token" if @publisher.authentication_token.nil?
    rescue => e
      require 'sentry-raven'
      Raven.capture_exception(e)
      raise
    end

    # Expired tokens are expected and will not be logged
    raise "expired token" if @publisher.authentication_token_expires_at <= Time.now
  end
end
