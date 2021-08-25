namespace :database_updates do
  desc 'Backfill Brave Publisher Id'
  task :backfill_brave_publisher_id => :environment do
    def handle_non_domain(details_name:)
=begin
      Creates an object like the following
      sql = """
      UPDATE channels
      SET derived_brave_publisher_id = concat('youtube#channel:', ycd.youtube_channel_id)
      FROM youtube_channel_details AS ycd
      WHERE channels.details_type = 'YoutubeChannelDetails'
      AND channels.details_id = ycd.id;
      """
=end

      company_name = details_name.split("Channel")[0].downcase # grabs youtube, twitter, etc.
      details_obj = details_name.constantize
      sql = """
      UPDATE channels
      SET derived_brave_publisher_id = concat('#{details_obj::PREFIX}', details.#{company_name}_channel_id)
      FROM #{details_name.underscore} as details
      WHERE channels.details_type = '#{details_name}'
      AND channels.details_id = details.id;
      """
      Channel.connection.execute(sql)
    end

    def handle_websites!
      sql = """
      UPDATE channels
      SET derived_brave_publisher_id = details.brave_publisher_id
      FROM site_channel_details AS details
      WHERE channels.details_type = 'SiteChannelDetails'
      AND channels.details_id = details.id;
      """
      Channel.connection.execute(sql)
    end

    handle_non_domain(details_name: GithubChannelDetails.name)
    handle_non_domain(details_name: RedditChannelDetails.name)
    handle_non_domain(details_name: TwitterChannelDetails.name)
    handle_non_domain(details_name: TwitchChannelDetails.name)
    handle_non_domain(details_name: VimeoChannelDetails.name)
    handle_non_domain(details_name: YoutubeChannelDetails.name)
    handle_websites!
    puts "Done!"
  end
end
