module Admin
  module ChannelTransfersHelper
    def transfer_details(transfer, is_suspended)
      image = image_tag(channel_type_icon_url(transfer.channel), size: "20x20", class: "mx-2")
      link = link_to(on_channel_type(transfer.channel), transfer.channel.details.url)
      suspended = nil
      suspended = content_tag(:div, 'Suspended Transfer', class: 'badge badge-danger ml-3') if is_suspended

      image + link + suspended
    end
  end
end
