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
=begin
    (Albert Wang): Disable this temporarily until we up our quota
    query = extract_channel_from_user(query) if is_youtube_user?(query)
    query = channel_from_video_url(query) if is_youtube_video?(query)
=end

    query.strip
  end

  # Returns an ActiveRecord::Relation of publishers for pagination
  def publishers_search(publishers, query)
    search_query = remove_prefix_if_necessary(params[:q])

    # Simple optimization to only search for the things that the admins search for the most
    if is_email?(search_query)
      results = publishers.where('email ILIKE ?', "%#{search_query}%")
    elsif is_promo_code?(search_query)
      results = publishers.left_joins(:channels).joins(channels: :promo_registration).where(promo_registrations: { referral_code: search_query.upcase })
    else
      search_query = "%#{search_query}%" unless is_a_uuid?(search_query)
      results = publishers.where(search_sql, search_query: search_query)
    end

    results
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
        LEFT JOIN uphold_connections ON uphold_connections.publisher_id = publishers.id
        WHERE publishers.email ILIKE :search_query
              OR publishers.name ILIKE :search_query
              OR publishers.id::text = :search_query
              OR uphold_connections.uphold_id::text = :search_query
      )
    }
  end


  private

  def is_promo_code?(string)
    string =~ /[a-zA-z]{3}[\d]{3}$/
  end

  def is_email?(string)
    string =~ /@.*?\./
  end

  def is_a_uuid?(uuid)
    # https://stackoverflow.com/questions/47508829/validate-uuid-string-in-ruby-rails
    uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
    uuid_regex.match?(uuid.to_s.downcase)
  end

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
