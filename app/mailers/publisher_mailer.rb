# typed: ignore

class PublisherMailer < ApplicationMailer
  include PublishersHelper
  helper PublishersHelper

  after_action :ensure_fresh_token,
    only: %i[login_email verify_email confirm_email_change]

  # Best practice is to use the MailerServices::PublisherLoginLinkEmailer service
  def login_email(publisher)
    @publisher = publisher
    @private_reauth_url = publisher_private_reauth_url(publisher: @publisher)
    I18n.with_locale(@publisher.last_supported_login_locale) do
      mail_if_destination_exists(
        to: @publisher.email,
        asm: transaction_asm_group_id,
        subject: default_i18n_subject
      )
    end
  end

  def payment_failure_email(publisher:)
    @publisher = publisher
    mail_if_destination_exists(
      to: @publisher.email,
      asm: transaction_asm_group_id,
      subject: default_i18n_subject
    )
  end

  def wallet_refresh_failure(publisher, wallet_provider)
    @publisher = publisher
    @publisher_log_in_url = log_in_publishers_url
    @wallet_provider = wallet_provider

    I18n.with_locale(@publisher.last_supported_login_locale) do
      mail_if_destination_exists(
        to: @publisher.email,
        asm: transaction_asm_group_id,
        subject: default_i18n_subject(wallet_provider: @wallet_provider)
      )
    end
  end

  def promo_breakdowns(publisher, attachment)
    attachments["promos.csv"] = attachment
    mail_if_destination_exists(
      to: publisher.email
    )
  end

  # Contains registration details and a private verify_email link
  # Best practice is to use the MailerServices::VerifyEmailEmailer service
  def verify_email(publisher:, locale: :en)
    @publisher = publisher
    @private_reauth_url = publisher_private_reauth_url(publisher: @publisher)

    if @publisher.pending_email.present?
      I18n.with_locale(locale) do
        mail_if_destination_exists(
          to: @publisher.pending_email,
          subject: default_i18n_subject
        )
      end
    else
      begin
        raise "SMTP To address must not be blank for PublisherMailer#verify_email for publisher #{@publisher.id}"
      rescue => e
        LogException.perform(e)
      end
    end
  end

  # TODO: Refactor
  # Like the above but without the verify_email link
  def verify_email_internal(publisher)
    raise unless self.class.should_send_internal_emails?
    @publisher = publisher
    @private_reauth_url = "{redacted}"
    mail_if_destination_exists(
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
    mail_if_destination_exists(
      to: @publisher.pending_email,
      subject: default_i18n_subject
    )
  end

  def confirm_email_change_internal(publisher)
    @publisher = publisher
    @private_reauth_url = "{redacted}"
    mail_if_destination_exists(
      to: INTERNAL_EMAIL,
      reply_to: @publisher.email,
      subject: "<Internal> #{t("publisher_mailer.confirm_email_change.subject")}",
      template_name: "confirm_email_change"
    )
  end

  def notify_email_change(publisher)
    @publisher = publisher
    mail_if_destination_exists(
      to: @publisher.email,
      asm: transaction_asm_group_id,
      subject: default_i18n_subject
    )
  end

  def uphold_kyc_incomplete(publisher, total_amount)
    @publisher = publisher
    @total_amount = total_amount
    mail_if_destination_exists(
      to: @publisher.email,
      subject: default_i18n_subject(total_amount: total_amount)
    )
  end

  def uphold_member_restricted(publisher)
    @publisher = publisher
    mail_if_destination_exists(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  def suspend_publisher(publisher)
    @publisher = publisher
    mail_if_destination_exists(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  def suspend_publisher_for_brand_bidding(publisher)
    @publisher = publisher
    mail_if_destination_exists(
      to: @publisher.email,
      from: ApplicationMailer::BRAND_BIDDING_EMAIL,
      subject: default_i18n_subject
    )
  end

  def suspend_publisher_for_brand_bidding_and_impersonation(publisher)
    @publisher = publisher
    mail_if_destination_exists(
      to: @publisher.email,
      from: ApplicationMailer::BRAND_BIDDING_EMAIL,
      subject: default_i18n_subject
    )
  end

  def two_factor_authentication_removal_cancellation(publisher)
    @publisher = publisher
    @publisher_private_two_factor_cancellation_url = publisher_private_two_factor_cancellation_url(publisher: @publisher)
    mail_if_destination_exists(
      to: @publisher.email,
      subject: default_i18n_subject,
      template_name: "two_factor_authentication_removal_cancellation"
    )
  end

  def two_factor_authentication_removal_reminder(publisher, remainder)
    @publisher = publisher
    @remainder = remainder
    mail_if_destination_exists(
      to: @publisher.email,
      subject: default_i18n_subject,
      template_name: "two_factor_authentication_removal_reminder"
    )
  end

  def channel_contested(channel)
    @channel = channel
    @channel_name = @channel.publication_title
    @publisher_name = @channel.publisher.name
    @email = @channel.publisher.email

    @transfer_url = reject_transfer_success_publishers_url(channel_name: @channel_name)

    mail_if_destination_exists(
      to: @email,
      subject: default_i18n_subject(channel_name: @channel.publication_title)
    )
  end

  def channel_contested_internal(channel)
    @channel_name = channel.publication_title
    @publisher_name = channel.publisher.name
    @email = channel.publisher.email

    @transfer_url = "{redacted}"

    mail_if_destination_exists(
      to: INTERNAL_EMAIL,
      reply_to: @email,
      subject: "<Internal> #{t("publisher_mailer.channel_contested.subject")}",
      template_name: "channel_contested"
    )
  end

  def channel_transfer_approved_primary(channel_name, publisher_name, email)
    @channel_name = channel_name
    @publisher_name = publisher_name
    @email = email

    mail_if_destination_exists(
      to: @email,
      subject: default_i18n_subject(channel_name: @channel_name)
    )
  end

  def channel_transfer_approved_primary_internal(channel_name, publisher_name, email)
    @channel_name = channel_name
    @publisher_name = publisher_name
    @email = email

    mail_if_destination_exists(
      to: INTERNAL_EMAIL,
      reply_to: @email,
      subject: "<Internal> #{t("publisher_mailer.channel_transfer_approved_primary.subject")}",
      template_name: "channel_transfer_approved_primary"
    )
  end

  def channel_transfer_approved_secondary(channel)
    @channel_name = channel.publication_title
    @publisher_name = channel.publisher.name
    @email = channel.publisher.email

    mail_if_destination_exists(
      to: @email,
      subject: default_i18n_subject(channel_name: @channel_name)
    )
  end

  def channel_transfer_approved_secondary_internal(channel)
    @channel_name = channel.publication_title
    @publisher_name = channel.publisher.name
    @email = channel.publisher.email

    mail_if_destination_exists(
      to: INTERNAL_EMAIL,
      reply_to: @email,
      subject: "<Internal> #{t("publisher_mailer.channel_transfer_approved_secondary.subject")}",
      template_name: "channel_transfer_approved_secondary"
    )
  end

  def channel_transfer_rejected_primary(channel)
    @channel_name = channel.publication_title
    @publisher_name = channel.publisher.name
    @email = channel.publisher.email

    mail_if_destination_exists(
      to: @email,
      subject: default_i18n_subject(channel_name: @channel_name)
    )
  end

  def channel_transfer_rejected_primary_internal(channel)
    @channel_name = channel.publication_title
    @publisher_name = channel.publisher.name
    @email = channel.publisher.email

    mail_if_destination_exists(
      to: INTERNAL_EMAIL,
      reply_to: @email,
      subject: "<Internal> #{t("publisher_mailer.channel_transfer_rejected_primary.subject")}",
      template_name: "channel_transfer_rejected_primary"
    )
  end

  def channel_transfer_rejected_secondary(channel_name, publisher_name, email)
    @channel_name = channel_name
    @publisher_name = publisher_name

    mail_if_destination_exists(
      to: email,
      subject: default_i18n_subject(channel_name: @channel_name)
    )
  end

  def channel_transfer_rejected_secondary_internal(channel_name, publisher_name, email)
    mail_if_destination_exists(
      to: INTERNAL_EMAIL,
      reply_to: email,
      subject: "<Internal> #{t("publisher_mailer.channel_transfer_rejected_primary.subject")}",
      template_name: "channel_transfer_rejected_secondary"
    )
  end

  def wallet_not_connected(publisher, total_amount)
    @publisher = publisher
    @publisher_log_in_url = log_in_publishers_url
    @total_amount = total_amount

    connection = @publisher.uphold_connection
    if connection&.uphold_verified? && connection&.address.present?
      begin
        raise "#{@publisher.id}'s wallet is connected."
      rescue => e
        LogException.perform(e)
      end
    else
      mail_if_destination_exists(
        to: @publisher.email,
        subject: default_i18n_subject(total_amount: total_amount)
      )
    end
  end

  def email_user_on_hold(publisher)
    @publisher = publisher

    mail_if_destination_exists(
      to: @publisher.email,
      from: ApplicationMailer::PAYOUT_CONTACT_EMAIL,
      subject: default_i18n_subject
    )
  end

  def submit_appeal(publisher)
    @name = publisher.name
    @body = I18n.t(".publisher_mailer.submit_appeal.body")

    mail_if_destination_exists(to: publisher.email,
      subject: I18n.t(".publisher_mailer.submit_appeal.subject"),
      template_name: "shared")
  end

  def accept_appeal(publisher)
    @name = publisher.name
    @body = I18n.t(".publisher_mailer.accept_appeal.body")

    mail_if_destination_exists(to: publisher.email,
      subject: I18n.t(".publisher_mailer.accept_appeal.subject"),
      template_name: "shared")
  end

  def reject_appeal(publisher)
    @name = publisher.name
    @body = I18n.t(".publisher_mailer.reject_appeal.body")

    mail_if_destination_exists(to: publisher.email,
      subject: I18n.t(".publisher_mailer.reject_appeal.subject"),
      template_name: "shared")
  end

  private

  def mail_if_destination_exists(*, **keyword_args)
    # Sometimes a job gets queued for a deleted user
    if keyword_args[:to].present?
      mail(*, **keyword_args)
    else
      LogException.perform(
        StandardError.new("Tried to mail a deleted user.")
      )
    end
  end

  # (Albert Wang): These are critical emails pertaining to login.
  # You can view the IDs here: https://mc.sendgrid.com/unsubscribe-groups
  def transaction_asm_group_id
    SendGrid::ASM.new(group_id: Rails.configuration.pub_secrets[:sendgrid_transactional_asm_group_id])
  end

  def ensure_fresh_token
    # Check if we are missing the token and capture to New Relic if we are. This should not happen.
    begin
      raise "missing token" if @publisher.authentication_token.nil?
    rescue => e
      LogException.perform(e)
      raise
    end

    # Expired tokens are expected and will not be logged
    raise "expired token" if @publisher.authentication_token_expires_at <= Time.now
  end
end
