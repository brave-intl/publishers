class PublisherMailer < ApplicationMailer
  include PublishersHelper
  add_template_helper(PublishersHelper)

  after_action :ensure_fresh_token,
    only: %i(login_email verify_email verification_done confirm_email_change)

  # Best practice is to use the MailerServices::PublisherLoginLinkEmailer service
  def login_email(publisher)
    @publisher = publisher
    @private_reauth_url = publisher_private_reauth_url(publisher: @publisher)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  # Best practice is to use the MailerServices::VerificationDoneEmailer service
  def verification_done(channel)
    @channel = channel
    @publisher = @channel.publisher
    @private_reauth_url = publisher_private_reauth_url(publisher: @publisher)
    path = Rails.root.join("app/assets/images/verified-icon.png")
    attachments.inline["verified-icon.png"] = File.read(path)
    mail(
        to: @publisher.email,
        subject: default_i18n_subject(publication_title: @channel.details.publication_title)
    )
  end

  # TODO: Refactor
  # Like the above but without the private access link
  def verification_done_internal(channel)
    raise if !self.class.should_send_internal_emails?
    @channel = channel
    @publisher = @channel.publisher
    @private_reauth_url = "{redacted}"
    path = Rails.root.join("app/assets/images/verified-icon.png")
    attachments.inline["verified-icon.png"] = File.read(path)
    mail(
        to: INTERNAL_EMAIL,
        reply_to: @publisher.email,
        subject: "<Internal> #{t("publisher_mailer.verification_done.subject", publication_title: @channel.details.publication_title)}",
        template_name: "verification_done"
    )
  end

  # Contains registration details and a private verify_email link
  # Best practice is to use the MailerServices::VerifyEmailEmailer service
  def verify_email(publisher)
    @publisher = publisher
    @private_reauth_url = publisher_private_reauth_url(publisher: @publisher)

    if @publisher.pending_email.present?
      mail(
          to: @publisher.pending_email,
          subject: default_i18n_subject
      )
    else
      begin
        raise "SMTP To address must not be blank for PublisherMailer#verify_email for publisher #{@publisher.id}"
      rescue => e
        require 'sentry-raven'
        Raven.capture_exception(e)
      end
    end
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
        subject: "<Internal> #{t("publisher_mailer.verify_email.subject")}",
        template_name: "verify_email"
    )
  end

  # Best practice is to use the MailerServices::ConfirmEmailChangeEmailer service
  def confirm_email_change(publisher)
    @publisher = publisher
    @private_reauth_url = publisher_private_reauth_url(publisher: @publisher, confirm_email: @publisher.pending_email)
    mail(
      to: @publisher.pending_email,
      subject: default_i18n_subject
    )
  end

  def confirm_email_change_internal(publisher)
    @publisher = publisher
    @private_reauth_url = "{redacted}"
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{t("publisher_mailer.confirm_email_change.subject")}",
      template_name: "confirm_email_change"
    )
  end

  def notify_email_change(publisher)
    @publisher = publisher
    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  def uphold_account_changed(publisher)
    @publisher = publisher
    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  def statement_ready(publisher_statement)
    @publisher_statement = publisher_statement
    @publisher = publisher_statement.publisher
    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  def suspended_publisher(publisher)
    @publisher = publisher
    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  def verified_no_wallet(publisher, params)
    @publisher = publisher
    @publisher_dashboard_url = root_url
    if @publisher.uphold_verified
      begin
        raise "Uphold verified publisher #{@publisher.id} cannot create Uphold wallet"
      rescue => e
        require 'sentry-raven'
        Raven.capture_exception(e)
      end
    else
      mail(
        to: @publisher.email,
        subject: default_i18n_subject
      )
    end
  end

  def verified_no_wallet_internal(publisher, params)
    @publisher = publisher
    @publisher_dashboard_url = root_url
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{t("publisher_mailer.verified_no_wallet.subject")}",
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
      subject: "<Internal> #{t("publisher_mailer.unverified_domain_reached_threshold.subject", publication_title: @domain)}",
      template_name: "unverified_domain_reached_threshold"
    )
  end

  def channel_contested(channel)
    @channel = channel
    @email = channel.publisher.email

    @transfer_url = reject_transfer_path(@channel)

    mail(
        to: @email,
        subject: default_i18n_subject
    )
  end

  def channel_contested_internal(channel)
    @channel = channel
    @email = channel.publisher.email

    @transfer_url = "{redacted}"

    mail(
        to: INTERNAL_EMAIL,
        reply_to: @email,
        subject: "<Internal> #{t("publisher_mailer.channel_contested.subject")}",
        template_name: "channel_contested"
    )
  end

  def channel_transfer_approved_primary(email, channel_name)
    @channel_name = channel_name
    @email = email

    mail(
        to: @email,
        subject: default_i18n_subject
    )
  end

  def channel_transfer_approved_primary_internal(email, channel_name)
    @channel_name = channel_name
    @email = email

    mail(
        to: INTERNAL_EMAIL,
        reply_to: @email,
        subject: "<Internal> #{t("publisher_mailer.channel_transfer_approved_primary.subject")}",
        template_name: "channel_transfer_approved_primary"
    )
  end

  def channel_transfer_approved_secondary(email, channel_name)
    @channel_name = channel_name
    @email = email

    mail(
        to: @email,
        subject: default_i18n_subject
    )
  end

  def channel_transfer_approved_secondary_internal(email, channel_name)
    @channel_name = channel_name
    @email = email

    mail(
        to: INTERNAL_EMAIL,
        reply_to: @email,
        subject: "<Internal> #{t("publisher_mailer.channel_transfer_approved_secondary.subject")}",
        template_name: "channel_transfer_approved_secondary"
    )
  end

  def channel_transfer_rejected_primary(channel)
    @channel = channel
    @email = channel.publisher.email

    mail(
        to: @email,
        subject: default_i18n_subject
    )
  end

  def channel_transfer_rejected_primary_internal(channel)
    @channel = channel
    @email = channel.publisher.email

    mail(
        to: INTERNAL_EMAIL,
        reply_to: @email,
        subject: "<Internal> #{t("publisher_mailer.channel_transfer_rejected_primary.subject")}",
        template_name: "channel_transfer_rejected_primary"
    )
  end

  def channel_transfer_rejected_secondary(email, channel_name)
    mail(
        to: email,
        subject: default_i18n_subject
    )
  end

  def channel_transfer_rejected_secondary_internal(email, channel_name)
    mail(
        to: INTERNAL_EMAIL,
        reply_to: email,
        subject: "<Internal> #{t("publisher_mailer.channel_transfer_rejected_primary.subject")}",
        template_name: "channel_transfer_rejected_primary"
    )
  end

  def verified_invalid_wallet(publisher, params)
    @publisher = publisher
    if !@publisher.uphold_verified
      begin
        raise "Non Uphold verified publisher #{@publisher.id} cannot reconnect to Uphold"
      rescue => e
        require 'sentry-raven'
        Raven.capture_exception(e)
      end
    else
      mail(
        to: @publisher.email,
        subject: default_i18n_subject
      )
    end
  end

  def verified_invalid_wallet_internal(publisher, params)
    @publisher = publisher
    return if !@publisher.uphold_verified
    mail(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{t("publisher_mailer.verified_invalid_wallet.subject")}",
      template_name: "verified_invalid_wallet"
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
