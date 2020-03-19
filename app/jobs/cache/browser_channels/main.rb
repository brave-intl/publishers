class Cache::BrowserChannels::Main
  include Sidekiq::Worker

  # Update the lookup tables
  def perform
    Channel.joined_verified_channels.each do |verified_channels|
      verified_channels = verified_channels.
        preload(:details).
        eager_load(:uphold_connection_for_channel).
        eager_load(publisher: :uphold_connection).
        eager_load(publisher: :site_banners).
        eager_load(:site_banner).
        includes(site_banner: { logo_attachment: :blob }).
        includes(site_banner: { background_image_attachment: :blob })

      verified_channels.find_each do |verified_channel|
        include_verified_channel(verified_channel)
      end
    end
  end
end
