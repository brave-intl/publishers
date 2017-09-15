class PublisherMailer < ApplicationMailer
  include PublishersHelper
  add_template_helper(PublishersHelper)

  def login_email(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end

  # TODO: Remove me. Deprecated.
  # Contains instructions on how to verify domain.
  # Should be safe to forward to webmaster / IT peeps.
  def verification(publisher)
    @publisher = publisher
    generator = PublisherVerificationFileGenerator.new(publisher: @publisher)
    attachments[generator.filename] = generator.generate_file_content
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end

  # TODO: Remove me. Deprecated.
  # TODO: Refactor
  def verification_internal(publisher)
    raise if !self.class.should_send_internal_emails?
    @publisher = publisher
    generator = PublisherVerificationFileGenerator.new(publisher: @publisher)
    attachments[generator.filename] = generator.generate_file_content
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{I18n.t(:subject, brave_publisher_id: @publisher.brave_publisher_id, scope: %w(publisher_mailer verification))}",
      template_name: "verification"
    )
  end

  def verification_done(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    path = Rails.root.join("app/assets/images/verified-icon.png")
    attachments.inline["verified-icon.png"] = File.read(path)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end

  # TODO: Refactor
  # Like the above but without the private access link
  def verification_done_internal(publisher)
    raise if !self.class.should_send_internal_emails?
    @publisher = publisher
    @private_reauth_url = "{redacted}"
    path = Rails.root.join("app/assets/images/verified-icon.png")
    attachments.inline["verified-icon.png"] = File.read(path)
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{I18n.t(:subject, brave_publisher_id: @publisher.brave_publisher_id, scope: %w(publisher_mailer verification_done))}",
      template_name: "verification_done"
    )
  end

  # Contains registration details and a private reauthentication link
  def welcome(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end

  # TODO: Refactor
  # Like the above but without the private access link
  def welcome_internal(publisher)
    raise if !self.class.should_send_internal_emails?
    @publisher = publisher
    @private_reauth_url = "{redacted}"
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{I18n.t(:subject, brave_publisher_id: @publisher.brave_publisher_id, scope: %w(publisher_mailer welcome))}",
      template_name: "welcome"
    )
  end

  # Contains registration details and a private verify_email link
  def verify_email(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    mail(
        to: @publisher.pending_email,
        subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end

  # TODO: Refactor
  # Like the above but without the verify_email link
  def verify_email_internal(publisher)
    raise if !self.class.should_send_internal_emails?
    @publisher = publisher
    @private_reauth_url = "{redacted}"
    mail(
        to: INTERNAL_EMAIL,
        reply_to: @publisher.email,
        subject: "<Internal> #{I18n.t(:subject, scope: %w(publisher_mailer verify_email))}",
        template_name: "welcome"
    )
  end

  def uphold_account_changed(publisher)
    @publisher = publisher
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end
end
