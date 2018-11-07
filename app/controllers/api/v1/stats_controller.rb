class Api::V1::StatsController < Api::BaseController
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

    while iterating_date <= Date.today
      new_result << [iterating_date.to_s, 0]
      iterating_date = iterating_date.next_day
    end

    new_result
  end
end
