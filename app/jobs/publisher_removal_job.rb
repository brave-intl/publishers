class PublisherRemovalJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find_by(id: publisher_id)
    SendGrid::DeleteEmailJob.perform_later(email: publisher.email)

    if publisher.last_status_update.status.in?([PublisherStatusUpdate::CREATED, PublisherStatusUpdate::ONBOARDING, PublisherStatusUpdate::ACTIVE])
      delete_for_normal_publishers(publisher: publisher)
    else
      delete_for_other_publishers(publisher: publisher)
    end
  end

  def delete_for_normal_publishers(publisher:)
    publisher.status_updates.create(status: PublisherStatusUpdate::DELETED)
    publisher.reload
    ActiveRecord::Base.transaction do
      publisher.update(email: nil)
      publisher.update(pending_email: nil)
      publisher.update(name: PublisherStatusUpdate::DELETED)

      # If they're signed in, they should not longer be signed in
      publisher.user_authentication_token.update(authentication_token_expires_at: Time.now) if publisher.user_authentication_token.present?
      publisher.update(current_sign_in_ip: nil)
      publisher.update(last_sign_in_ip: nil)
    end

    publisher.channels.pluck(:id).each do |channel_id|
      DeletePublisherChannelJob.perform_now(channel_id: channel_id)
    end

    # Paper trail retains all records: we destroy all historical PII and non-PII
    publisher.versions.destroy_all
  end

  def delete_for_other_publishers(publisher:)
    publisher.status_updates.create(status: PublisherStatusUpdate::DELETED)
    publisher.reload
    ActiveRecord::Base.transaction do
      publisher.update(email: nil)
      publisher.update(pending_email: nil)
      publisher.update(name: PublisherStatusUpdate::DELETED)

      # If they're signed in, they should not longer be signed in
      publisher.user_authentication_token.update(authentication_token_expires_at: Time.now) if publisher.user_authentication_token.present?
    end

    # Paper trail retains all records: we destroy all historical PII and non-PII
    publisher.versions.destroy_all
  end
end
