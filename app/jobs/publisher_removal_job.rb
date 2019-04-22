class PublisherRemovalJob < ApplicationJob
  queue_as :low

  def perform(publisher_id:, override: false)
    publisher = Publisher.find_by(publisher_id)
    return if publisher.suspended? && !override
    publisher.last_status_updates.create(status: PublisherStatusUpdate::DELETED)
    ActiveRecord::Base.transaction do
      publisher.update(email: "DELETED")
      publisher.update(name: "DELETED")
      # If they're signed in, they should not longer be signed in
      publisher.user_authentication_token.update(authorication_token_expires_at: Time.now)
      publisher.update(last_sign_in_ip: "192.168.1.1")
    end
    publisher.channels.pluck(:channel_id).each do |channel_id|
      DeletePublisherChannelJob.perform_now(channel_id: channel_id)
    end

    # Paper trail retains all records: we destroy all historical PII and non-PII
    publisher.versions.destroy_all
  end
end
