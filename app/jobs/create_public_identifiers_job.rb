class CreatePublicIdentifiersJob < ApplicationJob
  queue_as :low
  include Sidekiq::Throttled::Job

  sidekiq_throttle(concurrency: {limit: 2})

  def perform(channel_ids)
    channel_ids.each do |id|
      channel = Channel.find(id)
      channel.set_public_identifier!
    rescue => e
      puts "Could not update channel #{id}: #{e.message}"
    end
  end
end
