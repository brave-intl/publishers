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
    if params[:up_to_date].present?
      up_to_date = Date.parse(params[:up_to_date])
    end
    render(json: Publisher.statistical_totals(up_to_date: up_to_date.respond_to?(:strftime) ? up_to_date : 1.day.from_now), status: 200)
  end
end
