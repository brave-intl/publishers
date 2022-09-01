# typed: ignore

# A list of Site Channels which require manual admin approval in addition to the
# standard verification flow.

module Publishers
  module RestrictedChannels
    def self.brave_publisher_id_list
      @@brave_publisher_id_list ||= begin
        file_path = Rails.root.join("config/restricted_site_channels.yml")
        Set.new(YAML.load_file(file_path))
      end
    end

    def self.restricted?(thing)
      if thing.is_a?(Channel)
        restricted?(thing.details)
      elsif thing.is_a?(SiteChannelDetails)
        restricted_brave_publisher_id?(thing.brave_publisher_id)
      # TODO Replace this check with general Details check.
      elsif thing.is_a?(TwitchChannelDetails) || thing.is_a?(YoutubeChannelDetails)
        false
      else
        Rails.logger.warn("Checked verification restriction on something which is not a Channel or ChannelDetails.")
        false
      end
    end

    def self.restricted_brave_publisher_id?(brave_publisher_id)
      brave_publisher_id_list.include?(brave_publisher_id)
    end
  end
end
