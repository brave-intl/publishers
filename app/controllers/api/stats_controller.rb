class Api::StatsController < Api::BaseController
  def signups_per_day
    sql =
    """
      select created_at::date, count(*)
      from publishers
      where role = 'publisher'
      group by created_at::date
      order by created_at::date
    """
    result = ActiveRecord::Base.connection.execute(sql).values
    render(json: fill_in_blank_dates(result).to_json, status: 200)
  end

  def email_verified_signups_per_day
    sql =
    """
      select created_at::date, count(*)
      from publishers
      where role = 'publisher'
      and email is not null
      group by created_at::date
      order by created_at::date
    """
    result = ActiveRecord::Base.connection.execute(sql).values
    render(json: fill_in_blank_dates(result).to_json, status: 200)
  end

  # Returns an array of buckets of site channel ids, where each bucket is defined by total channel views
  def twitch_channels_by_view_count
    # 0 - 1000 views
    bucket_one = TwitchChannelDetails.where("stats -> 'view_count' >= ?", "0").
                                      where("stats -> 'view_count' < ?", "1000").
                                      select(:id).map {|details| details.id}

    # 1000 - 10,000 views
    bucket_two = TwitchChannelDetails.where("stats -> 'view_count' >= ?", "1000").
                                      where("stats -> 'view_count' < ?", "10000").
                                      select(:id).map {|details| details.id}
    # 10,000 - 100,000 views
    bucket_three = TwitchChannelDetails.where("stats -> 'view_count' >= ?", "10000").
                                        where("stats -> 'view_count' < ?", "100000").
                                        select(:id).map {|details| details.id}
    # >= 100,000
    bucket_four = TwitchChannelDetails.where("stats -> 'view_count' >= ?", "100000").
                                       select(:id).map {|details| details.id}

    render(json: [bucket_one, bucket_two, bucket_three, bucket_four].to_json, status: 200)
  end

  def youtube_channels_by_view_count
    # 0 - 1000 views
    bucket_one = YoutubeChannelDetails.where("stats -> 'view_count' >= ?", "0").
                                       where("stats -> 'view_count' < ?", "1000").
                                       select(:id).map {|details| details.id}

    # 1000 - 10,000 views
    bucket_two = YoutubeChannelDetails.where("stats -> 'view_count' >= ?", "1000").
                                       where("stats -> 'view_count' < ?", "10000").
                                       select(:id).map {|details| details.id}
    # 10,000 - 100,000 views
    bucket_three = YoutubeChannelDetails.where("stats -> 'view_count' >= ?", "10000").
                                         where("stats -> 'view_count' < ?", "100000").
                                         select(:id).map {|details| details.id}
    # >= 100,000
    bucket_four = YoutubeChannelDetails.where("stats -> 'view_count' >= ?", "100000").
                                        select(:id).map {|details| details.id}

    render(json: [bucket_one, bucket_two, bucket_three, bucket_four].to_json, status: 200)
  end

  def javascript_enabled_usage

    active_users_with_javascript_enabled = Publisher
      .distinct
      .joins("inner join channels on channels.publisher_id = publishers.id")
      .where.not(javascript_last_detected_at: nil)
      .where("publishers.created_at > ?", Publisher::JAVASCRIPT_DETECTED_RELEASE_TIME)
      .count

    active_users_with_javascript_disabled = Publisher
      .distinct
      .joins("inner join channels on channels.publisher_id = publishers.id")
      .where(javascript_last_detected_at: nil)
      .where("publishers.created_at > ?", Publisher::JAVASCRIPT_DETECTED_RELEASE_TIME).count
    render(
      json: {
        active_users_with_javascript_enabled: active_users_with_javascript_enabled,
        active_users_with_javascript_disabled: active_users_with_javascript_disabled,
      },
      status: 200
    )
  end

  private

  def fill_in_blank_dates(result)
    new_result = [] # [['2018-06-01', count], ['2018-06-02, count]]
    iterating_date = Date.parse(result[0][0])

    result.each do |segment|
      # segment is ['2018-06-01', count]
      current_date = Date.parse(segment[0])
      while iterating_date < current_date
        new_result << [iterating_date.to_s, 0]
        iterating_date = iterating_date.next_day
      end
      if iterating_date == current_date
        new_result << segment
        iterating_date = iterating_date.next_day
      end
    end

    while iterating_date < Date.today
      new_result << [iterating_date.to_s, 0]
      iterating_date = iterating_date.next_day
    end

    new_result
  end
end
