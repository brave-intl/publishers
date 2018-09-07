# Preview all emails at https://localhost:3000/rails/mailers
# Preview publisher_mailer emails at https://localhost:3000/rails/mailers/publisher_mailer
class PublisherMailerPreview < ActionMailer::Preview

  def login_email
    PublisherMailer.login_email(Publisher.first, true)
  end

  def verify_email
    PublisherMailer.verify_email(Publisher.first, true)
  end

  def verification_done
    PublisherMailer.verification_done(Channel.first, true)
  end

  def verification_done_internal
    PublisherMailer.verification_done_internal(Channel.first)
  end

  def uphold_account_changed
    PublisherMailer.uphold_account_changed(Publisher.first)
  end

  def verified_no_wallet
    PublisherMailer.verified_no_wallet(Publisher.first, nil)
  end

  def verified_no_wallet_internal
    PublisherMailer.verified_no_wallet(Publisher.first, nil)
  end

  def verified_no_wallet_internal
    PublisherMailer.verified_no_wallet(Publisher.first, nil)
  end

  def channel_contested
    channel = Channel.where("contested_by_channel_id is not null").first
    PublisherMailer.channel_contested(channel)
  end

  def channel_contested_internal
    channel = Channel.where("contested_by_channel_id is not null").first
    PublisherMailer.channel_contested_internal(channel)
  end

  def channel_transfer_approved_primary
    PublisherMailer.channel_transfer_approved_primary("test@test.com", "My Channel")
  end

  def channel_transfer_approved_primary_internal
    PublisherMailer.channel_transfer_approved_primary_internal("test@test.com", "My Channel")
  end

  def channel_transfer_approved_secondary
    PublisherMailer.channel_transfer_approved_secondary("test@test.com", "My Channel")
  end

  def channel_transfer_approved_secondary_internal
    PublisherMailer.channel_transfer_approved_secondary_internal("test@test.com", "My Channel")
  end

  def channel_transfer_rejected_primary
    channel = Channel.where("contested_by_channel_id is not null").first
    PublisherMailer.channel_transfer_rejected_primary(channel)
  end

  def channel_transfer_rejected_primary_internal
    channel = Channel.where("contested_by_channel_id is not null").first
    PublisherMailer.channel_transfer_rejected_primary_internal(channel)
  end

  def channel_transfer_rejected_secondary
    channel = Channel.where("contested_by_channel_id is not null").first
    PublisherMailer.channel_transfer_rejected_secondary("test@test.com", "My Channel")
  end

  def channel_transfer_rejected_secondary_internal
    channel = Channel.where("contested_by_channel_id is not null").first
    PublisherMailer.channel_transfer_rejected_secondary_internal("test@test.com", "My Channel")
  end
end
