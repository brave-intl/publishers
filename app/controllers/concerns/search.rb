module Search
  extend ActiveSupport::Concern

  def remove_prefix_if_necessary(query)
    query = query.sub("publishers#uuid:", "")
    query = query.sub("youtube#channel:", "")
    query = query.sub("twitch#channel:", "")
    query = query.sub("twitch#author:", "")
    query = query.sub("twitter#channel:", "")
    query = query.sub("https://", "")
    query = query.sub("www.", "")

    # Replaces the query with the Youtube Channel someone pastes in a youtube video
    query = extract_channel(query) if query.include? "youtube.com/channel/"
    query = extract_channel_from_user(query) if is_youtube_user?(query)
    query = channel_from_video_url(query) if is_youtube_video?(query)

    query.strip
  end

  def channel_from_video_url(query)
    YoutubeVideoGetter.new(id: extract_video_id(query)).perform
  end

  # Returns an array of publisher ids that match the query
  def search_sql
    %{
      publishers.id IN
      (
        SELECT publishers.id FROM publishers
        INNER JOIN (
          SELECT channels.publisher_id
          FROM channels
            LEFT JOIN site_channel_details ON site_channel_details.id = channels.details_id
            LEFT JOIN youtube_channel_details ON youtube_channel_details.id = channels.details_id
            LEFT JOIN twitch_channel_details ON twitch_channel_details.id = channels.details_id
            LEFT JOIN promo_registrations ON promo_registrations.channel_id = channels.id
          WHERE
            site_channel_details.brave_publisher_id ILIKE :search_query
            OR promo_registrations.referral_code ILIKE :search_query
            OR youtube_channel_details.title ILIKE :search_query
            OR youtube_channel_details.youtube_channel_id ILIKE :search_query
            OR twitch_channel_details.NAME ILIKE :search_query
          ) channel_search
        ON channel_search.publisher_id = publishers.id

        UNION ALL

        SELECT publishers.id
        FROM publishers
        WHERE publishers.email ILIKE :search_query
              OR publishers.name ILIKE :search_query
              OR publishers.id::text = :search_query
              OR publishers.uphold_id::text = :search_query
      )
    }
  end


  private

  def is_youtube_video?(query)
    query.include?('youtube.com/watch?v=') || query.include?('youtu.be/')
  end

  def is_youtube_user?(query)
    query.include?('youtube.com/user/')
  end

  def extract_channel(query)
    query = query.sub('youtube.com/channel/', '')
    query = query.split('&').first
    query = query.split('?').first

    query
  end

  def extract_channel_from_user(query)
    query = query.sub("youtube.com/user/", "")
    query = query.split('/').first
    user = YoutubeUserGetter.new(user: query).perform
    user || ''
  end

  def extract_video_id(query)
    query = query.sub('youtube.com/watch?v=', '')
    query = query.sub('youtu.be/', '')
    query = query.split('&').first
    query = query.split('?').first

    query
  end
end
