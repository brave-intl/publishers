namespace :database_updates do
  task :remove_unused_versions => :environment do
    class LegacyVersion < ApplicationRecord ; end
    class Version < ApplicationRecord ; end
    puts "[#{Time.now.iso8601}] Starting migration to remove unused version details"

    LegacyVersion.where(item_type: YoutubeChannelDetails.to_s).delete_all
    LegacyVersion.where(item_type: SiteChannelDetails.to_s).delete_all
    LegacyVersion.where(item_type: PotentialPayment.to_s).delete_all
    LegacyVersion.where(item_type: TwitchChannelDetails.to_s).delete_all
    LegacyVersion.where(item_type: TwitterChannelDetails.to_s).delete_all
    Version.where(item_type: YoutubeChannelDetails.to_s).delete_all
    Version.where(item_type: SiteChannelDetails.to_s).delete_all
    Version.where(item_type: PotentialPayment.to_s).delete_all
    Version.where(item_type: TwitchChannelDetails.to_s).delete_all
    Version.where(item_type: TwitterChannelDetails.to_s).delete_all
    puts "[#{Time.now.iso8601}] - migration complete ✨"
  end
end
