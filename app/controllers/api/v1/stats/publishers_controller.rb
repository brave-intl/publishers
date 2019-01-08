class Api::V1::Stats::PublishersController < Api::V1::StatsController
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

  def channel_and_email_verified_signups_per_day
    sql =
    """
      select p.created_at::date, count(*)
      from (
        select distinct publishers.*
        from publishers
        inner join channels
        on channels.publisher_id = publishers.id and channels.verified = true
        where role = 'publisher'
        and email is not null
      ) as p
      group by p.created_at::date
      order by p.created_at::date
    """
    result = ActiveRecord::Base.connection.execute(sql).values
    render(json: fill_in_blank_dates(result).to_json, status: 200)
  end

  def channel_uphold_and_email_verified_signups_per_day
    sql =
    """
      select p.created_at::date, count(*)
      from (
        select distinct publishers.*
        from publishers
        inner join channels
        on channels.publisher_id = publishers.id and channels.verified = true
        where role = 'publisher'
        and uphold_verified = true
        and email is not null
      ) as p
      group by p.created_at::date
      order by p.created_at::date
    """
    result = ActiveRecord::Base.connection.execute(sql).values
    render(json: fill_in_blank_dates(result).to_json, status: 200)
  end

  def totals
    render(json: Publisher.statistical_totals, status: 200)
  end

  def javascript_enabled_usage
    active_users_with_javascript_enabled = Publisher.
      distinct.
      joins("inner join channels on channels.publisher_id = publishers.id").
      where.not(javascript_last_detected_at: nil).
      where("publishers.last_sign_in_at > ?", Publisher::JAVASCRIPT_DETECTED_RELEASE_TIME).
      count

    active_users_with_javascript_disabled = Publisher.
      distinct.
      joins("inner join channels on channels.publisher_id = publishers.id").
      where(javascript_last_detected_at: nil).
      where("publishers.last_sign_in_at > ?", Publisher::JAVASCRIPT_DETECTED_RELEASE_TIME).
      count

    render(
      json: {
        active_users_with_javascript_enabled: active_users_with_javascript_enabled,
        active_users_with_javascript_disabled: active_users_with_javascript_disabled,
      },
      status: 200
    )
  end
end
