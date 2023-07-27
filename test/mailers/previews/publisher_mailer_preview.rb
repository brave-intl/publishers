# typed: false

# Preview all emails at https://localhost:3000/rails/mailers
# Consider moving away from mailcatcher to use https://github.com/fgrehm/letter_opener_web
# Also, is this test just dead?
class PublisherMailerPreview < ActionMailer::Preview
  def login_email
    PublisherTokenGenerator.new(publisher: Publisher.first).perform
    PublisherMailer.login_email(Publisher.first)
  end

  def login_partner_email
    PublisherTokenGenerator.new(publisher: Publisher.first).perform
    PublisherMailer.login_email(Publisher.first)
  end

  def verify_email
    publisher = Publisher.first
    publisher&.pending_email = "test@brave.com"
    PublisherTokenGenerator.new(publisher: Publisher.first).perform
    PublisherMailer.verify_email(publisher: publisher)
  end

  def payment_failure_email
    publisher = Publisher.first
    publisher&.pending_email = "test@brave.com"
    PublisherTokenGenerator.new(publisher: Publisher.first).perform
    PublisherMailer.payment_failure_email(publisher: publisher)
  end

  def wallet_refresh_failure
    PublisherMailer.wallet_refresh_failure(Publisher.first, "Uphold")
  end

  def wallet_not_connected
    PublisherMailer.wallet_not_connected(Publisher.first, 232.4)
  end

  def uphold_kyc_incomplete
    PublisherMailer.uphold_kyc_incomplete(Publisher.first, 232.4)
  end

  def uphold_member_restricted
    PublisherMailer.uphold_member_restricted(Publisher.first)
  end

  def channel_contested
    channel = Channel.first
    channel.contest_token = ""
    PublisherMailer.channel_contested(channel)
  end

  def channel_transfer_approved_primary
    PublisherMailer.channel_transfer_approved_primary("My Channel", "Test", "test@test.com")
  end

  def channel_transfer_approved_secondary
    PublisherMailer.channel_transfer_approved_secondary(Channel.first)
  end

  def channel_transfer_rejected_primary
    PublisherMailer.channel_transfer_rejected_primary(Channel.first)
  end

  def channel_transfer_rejected_secondary
    PublisherMailer.channel_transfer_rejected_secondary("My Channel", "test", "test@test.com")
  end

  def suspend_publisher
    PublisherMailer.suspend_publisher(Publisher.first)
  end

  def notify_email_change
    publisher = Publisher.first
    publisher.pending_email = "pending@brave.com"
    PublisherMailer.notify_email_change(publisher)
  end

  def confirm_email_change
    publisher = Publisher.first
    publisher.pending_email = "pending@brave.com"
    PublisherTokenGenerator.new(publisher: Publisher.first).perform
    PublisherMailer.confirm_email_change(publisher)
  end

  def tagged_in_note
    InternalMailer.tagged_in_note(tagged_user: Publisher.where(role: "admin").first, note: PublisherNote.where("note LIKE ?", "%@%").first)
  end

  def email_user_on_hold
    PublisherMailer.email_user_on_hold(Publisher.first)
  end

  def update_to_tos
    BatchMailer.update_to_tos(Publisher.first)
  end

  def kyc_and_referral_update
    BatchMailer.notification_for_kyc(Publisher.first)
  end

  def submit_appeal
    PublisherMailer.submit_appeal(Publisher.first)
  end

  def accept_appeal
    PublisherMailer.accept_appeal(Publisher.first)
  end

  def reject_appeal
    PublisherMailer.reject_appeal(Publisher.first)
  end
end
