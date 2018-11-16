module Search
  extend ActiveSupport::Concern

  def remove_prefix_if_necessary(query)
    query = query.sub("publishers#uuid:", "")
    query = query.sub("youtube#channel:", "")
    query = query.sub("twitch#channel:", "")
    query = query.sub("twitch#author:", "")
    query = query.sub("twitter#channel:", "")
  end


  # Returns an array of publisher ids that match the query
  def search_sql
    %{
      publishers.id IN
      (
        SELECT publishers.id
        FROM   publishers
              INNER JOIN(SELECT channels.*
                          FROM   channels
                                INNER JOIN site_channel_details
                                        ON site_channel_details.id = channels.details_id
                                            AND channels.details_type = 'SiteChannelDetails'
                                            AND site_channel_details.brave_publisher_id ILIKE ?
                          UNION ALL
                          SELECT channels.*
                          FROM   channels
                                INNER JOIN youtube_channel_details
                                        ON youtube_channel_details.id =
                                            channels.details_id
                                            AND youtube_channel_details.title ILIKE ?
                                            OR youtube_channel_details.youtube_channel_id ILIKE ?
                          UNION ALL
                          SELECT channels.*
                          FROM   channels
                                INNER JOIN twitch_channel_details
                                        ON twitch_channel_details.id = channels.details_id
                                            AND twitch_channel_details.NAME ILIKE ?)
                                          c
                      ON c.publisher_id = publishers.id
        UNION ALL
        SELECT publishers.id
        FROM publishers
        WHERE publishers.email ILIKE ?
              OR publishers.name ILIKE ?
              OR publishers.id::text = ?
      )
    }
  end
end
