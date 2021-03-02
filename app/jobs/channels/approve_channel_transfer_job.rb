module Channels
  class ApproveChannelTransferJob < ApplicationJob
    queue_as :low

    def perform(channel_id:)
      channel = Channel.find(channel_id)

      ActiveRecord::Base.transaction do
        contested_by = channel.contested_by_channel

        ## There is a helper function in channel.rb that can help minimize this code
        ## Need to generate new bF deposit ID on channel transfer:
        channel.deposit_id = nil
        if contested_by.publisher.selected_wallet_provider_type == BITFLYER_CONNECTION
          # Request a deposit id from bitFlyer.
          url = URI.parse(Rails.application.secrets[:bitflyer_host] + '/api/link/v1/account/create-deposit-id?request_id=' + SecureRandom.uuid)
          request = Net::HTTP::Get.new(url.to_s)
          request['Authorization'] = "Bearer " + contested_by.publisher.bitflyer_connection.access_token
          response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            http.request(request)
          end
          deposit_id = JSON.parse(response.body)["deposit_id"]
          contested_by.update(deposit_id: deposit_id)
        end
        ###################################################################

        channel.contested_by_channel_id = nil
        channel.contest_token = nil
        channel.contest_timesout_at = nil

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
