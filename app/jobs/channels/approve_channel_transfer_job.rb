# typed: ignore
module Channels
  class ApproveChannelTransferJob < ApplicationJob
    queue_as :low

    def perform(channel_id:)
      channel = Channel.find(channel_id)

      ActiveRecord::Base.transaction do
        contested_by = channel.contested_by_channel

        # New deposit ids will be created async via scheduled job if
        # the wallet provider is valid
        channel.deposit_id = nil
        channel.contested_by_channel_id = nil
        channel.contest_token = nil
        channel.contest_timesout_at = nil
        channel.verified = false

        channel.save!

        original_owner_email = channel.publisher.email
        original_owner_name = channel.publisher.name
        channel_name = channel.publication_title

        contested_by.verification_succeeded!(false)
        channel.destroy

        # Email the original owner
        PublisherMailer.channel_transfer_approved_primary(channel_name, original_owner_name, original_owner_email).deliver_later
        PublisherMailer.channel_transfer_approved_primary_internal(channel_name, original_owner_name, original_owner_email).deliver_later

        # Email the new owner
        PublisherMailer.channel_transfer_approved_secondary(contested_by).deliver_later
        PublisherMailer.channel_transfer_approved_secondary_internal(contested_by).deliver_later
      end
    end
  end
end
