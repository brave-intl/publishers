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

    def self.restricted_brave_publisher_id?(brave_publisher_id)
      brave_publisher_id_list.include?(brave_publisher_id)
    end
  end
end