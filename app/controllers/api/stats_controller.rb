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

  def verified_signups_per_day
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
