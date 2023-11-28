# typed: ignore

module Channels
  class UpdateSiteBannerLookupJob < ApplicationJob
    queue_as :low

    def perform(channel_id:)
      Channel.find(channel_id)&.update_site_banner_lookup!
    end
  end
end
