
# Preview all emails at https://localhost:3000/rails/mailers

class PublisherMailerInternalPreview < ActionMailer::Preview

  def verification_done_internal
    PublisherMailer.verification_done_internal(Channel.first)
  end

  def channel_contested_internal
    PublisherMailer.channel_contested_internal(Channel.first)
  end

  def channel_transfer_approved_primary_internal
    PublisherMailer.channel_transfer_approved_primary_internal("My Channel", "Test", "test@test.com")
  end

  def channel_transfer_approved_secondary_internal
    PublisherMailer.channel_transfer_approved_secondary_internal(Channel.first)
  end

  def channel_transfer_rejected_primary_internal
    PublisherMailer.channel_transfer_rejected_primary_internal(Channel.first)
  end

  def channel_transfer_rejected_secondary_internal
    channel = Channel.where("contested_by_channel_id is not null").first
    PublisherMailer.channel_transfer_rejected_secondary_internal("My Channel", "test", "test@test.com")
  end

  def confirm_email_change_internal
    publisher = Publisher.first
    publisher.pending_email = 'pending@brave.com'
    PublisherMailer.confirm_email_change_internal(publisher)
  end

end
