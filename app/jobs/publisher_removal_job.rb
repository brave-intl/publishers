class PublisherRemovalJob < ApplicationJob
  queue_as :default

  DELETED_IP_ADDRESS = "192.168.1.1".freeze

  def perform(publisher_id:)
    publisher = Publisher.find_by(id: publisher_id)
    return if publisher.suspended?
    publisher.status_updates.create(status: PublisherStatusUpdate::DELETED)
    ActiveRecord::Base.transaction do
      publisher.update(email: nil)
      publisher.update(pending_email: nil)
      publisher.update(name: PublisherStatusUpdate::DELETED)
      publisher.update(phone: nil)
      publisher.update(phone_normalized: nil)
      # If they're signed in, they should not longer be signed in
      publisher.user_authentication_token.update(authentication_token_expires_at: Time.now) if publisher.user_authentication_token.present?
      publisher.update(current_sign_in_ip: DELETED_IP_ADDRESS)
      publisher.update(last_sign_in_ip: DELETED_IP_ADDRESS)
    end
    publisher.channels.pluck(:id).each do |channel_id|
      DeletePublisherChannelJob.perform_now(channel_id: channel_id)
    end

    # Paper trail retains all records: we destroy all historical PII and non-PII
    publisher.versions.destroy_all
  end
end
