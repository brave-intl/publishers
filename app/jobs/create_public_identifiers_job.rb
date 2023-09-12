class CreatePublicIdentifiersJob < ApplicationJob
  queue_as :low

  def perform(channel_ids)
    channel_ids.each do |id|
      channel = Channel.find(id)
      channel.set_public_identifier!
    rescue => e
      puts "Could not update channel #{id}: #{e.message}"
    end
  end
end
