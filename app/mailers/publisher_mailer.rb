class PublisherMailer < ApplicationMailer
  include PublishersHelper
  add_template_helper(PublishersHelper)

  def login_email(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(publication_title: @publisher.publication_title)
    )
  end

  def verification_done(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    path = Rails.root.join("app/assets/images/verified-icon.png")
    attachments.inline["verified-icon.png"] = File.read(path)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(publication_title: @publisher.publication_title)
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
      subject: "<Internal> #{I18n.t(:subject, publication_title: @publisher.publication_title, scope: %w(publisher_mailer verification_done))}",
      template_name: "verification_done"
    )
  end

  # Contains registration details and a private reauthentication link
  def welcome(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(publication_title: @publisher.publication_title)
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
      subject: "<Internal> #{I18n.t(:subject, publication_title: @publisher.publication_title, scope: %w(publisher_mailer welcome))}",
      template_name: "welcome"
    )
  end

  # Contains registration details and a private verify_email link
  def verify_email(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher)

    if @publisher.pending_email.blank?
      begin
        raise "SMTP To address must not be blank for PublisherMailer#verify_email"
      rescue => e
        require 'sentry-raven'
        Raven.capture_exception(e,
                                publisher: @publisher,
                                publication_type: @publisher.publication_type)
      end
    end
    mail(
        to: @publisher.pending_email,
        subject: default_i18n_subject(publication_title: @publisher.publication_title)
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
        template_name: "verify_email"
    )
  end

  def confirm_email_change(publisher)
    @publisher = publisher
    @private_reauth_url = generate_publisher_private_reauth_url(@publisher, @publisher.pending_email)
    mail(
      to: @publisher.pending_email,
      subject: default_i18n_subject(publication_title: @publisher.publication_title)
    )
  end

  def confirm_email_change_internal(publisher)
    @publisher = publisher
    @private_reauth_url = "{redacted}"
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{I18n.t(:subject, publication_title: @publisher.publication_title, scope: %w(publisher_mailer confirm_email_change))}",
      template_name: "confirm_email_change"
    )
  end

  def notify_email_change(publisher)
    @publisher = publisher
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(publication_title: @publisher.publication_title)
    )
  end

  def uphold_account_changed(publisher)
    @publisher = publisher
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(publication_title: @publisher.publication_title)
    )
  end

  def statement_ready(publisher_statement)
    @publisher_statement = publisher_statement
    @publisher = publisher_statement.publisher
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(publication_title: @publisher.publication_title)
    )
  end

  def verified_no_wallet(publisher, params)
    @publisher = publisher
    @publisher_dashboard_url = root_url
    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  def verified_no_wallet_internal(publisher, params)
    @publisher = publisher
    @publisher_dashboard_url = root_url
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{I18n.t(:subject, scope: %w(publisher_mailer verified_no_wallet))}",
      template_name: "verified_no_wallet"
    )
  end

  def unverified_domain_reached_threshold(domain, email)
    @domain = domain
    @email = email
    @home_url = root_url
    mail(
      to: @email,
      subject: default_i18n_subject(publication_title: @domain)
    )
  end

  def unverified_domain_reached_threshold_internal(domain, email)
    @domain = domain
    @email = email
    @home_url = root_url
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @email,
      subject: "<Internal> #{I18n.t(:subject, publication_title: @domain, scope: %w(publisher_mailer unverified_domain_reached_threshold))}",
      template_name: "unverified_domain_reached_threshold"
    )
  end
end
