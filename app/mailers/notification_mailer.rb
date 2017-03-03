# TODO: Create Notification class
class NotificationMailer < ApplicationMailer
  include PublishersHelper
  add_template_helper(PublishersHelper)

  def publisher_form_retry(publisher, params = {})
    @message = params[:message] if params.present?
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end

  # TODO: Refactor
  def publisher_form_retry_internal(publisher, _params = {})
    raise if !self.class.should_send_internal_emails?
    @publisher = publisher
    @private_reauth_url = "{redacted}"

    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{I18n.t(:subject, brave_publisher_id: @publisher.brave_publisher_id, scope: %w(notification_mailer publisher_form_retry))}",
      template_name: "publisher_form_retry"
    )
  end

  def publisher_payments_activated(publisher, _params = {})
    @publisher = publisher
    @bitcoin_address = @publisher.bitcoin_address
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end

  # TODO: Refactor
  def publisher_payments_activated_internal(publisher, _params = {})
    raise if !self.class.should_send_internal_emails?
    @publisher = publisher
    @bitcoin_address = "{redacted}"
    @private_reauth_url = "{redacted}"

    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{I18n.t(:subject, brave_publisher_id: @publisher.brave_publisher_id, scope: %w(notification_mailer publisher_payments_activated))}",
      template_name: "publisher_payments_activated"
    )
  end
end
