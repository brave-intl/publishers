# Builds a list of verified and exluded channels for the Brave Browser
# ex.
# [
#     {
#         channelId: "brave.com",
#         verified: true,
#         excluded: false
#     },
#     {
#         channelId: "123.gov",
#         verified: true,
#         excluded: false
#     }
# ]
class JsonBuilders::ChannelsJsonBuilder
  def initialize
    require "publishers/excluded_channels"
    @excluded_channel_ids = Publishers::ExcludedChannels.brave_publisher_id_list
    @verified_channels = Channel.verified
    @excluded_verified_channel_ids = []
  end

  def build
    Jbuilder.encode do |json|
      json.array! @verified_channels.find_each do |verified_channel|
        json.channelId verified_channel.details.channel_identifier
        json.verified true
        if @excluded_channel_ids.include?(verified_channel.details.channel_identifier)
          json.excluded true
          @excluded_verified_channel_ids.push(verified_channel.details.channel_identifier)
        else
          json.excluded false
        end
      end

      json.array! @excluded_channel_ids.each do |excluded_channel_id|
        # skip if excluded channel is verified, since it's already been accounted
        next if @excluded_verified_channel_ids.include?(excluded_channel_id)
        json.channelId excluded_channel_id
        json.verified false
        json.excluded true
      end
    end
  end
end