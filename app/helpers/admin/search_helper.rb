module Admin
  module SearchHelper
    def channel_search_result_icon(channel)
      channel_type = channel.split('#')[0]
      if Channel::PROPERTIES.include?(channel_type)
        asset_url("publishers-home/#{channel_type}-icon_32x32.png")
      else
        asset_url('publishers-home/website-icon_32x32.png')
      end
    end
  end
end
