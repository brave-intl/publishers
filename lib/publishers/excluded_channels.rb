# A list of Site Channels which require manual admin approval in addition to the
# standard verification flow.

module Publishers
  module ExcludedChannels
    def self.brave_publisher_id_list
      @@brave_publisher_id_list ||= begin
        file_path = Rails.root.join("config/excluded_site_channels.yml")
        Set.new(YAML.load_file(file_path))
      end
    end

    def self.excluded?(thing)
      if thing.kind_of?(Channel)
        excluded?(thing.details)
      elsif thing.kind_of?(SiteChannelDetails)
        excluded_brave_publisher_id?(thing.brave_publisher_id)
      # TODO Replace this check with general Details check.
      elsif thing.kind_of?(TwitchChannelDetails) || thing.kind_of?(YoutubeChannelDetails)
        false
      else
        Rails.logger.warn("Checked verification exclusion on something which is not a Channel or ChannelDetails.")
        false
      end
    end

    def self.excluded_brave_publisher_id?(brave_publisher_id)
      brave_publisher_id_list.include?(brave_publisher_id)
    end
  end
end
