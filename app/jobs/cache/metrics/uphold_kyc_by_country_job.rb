class Cache::Metrics::UpholdKycByCountryJob < ApplicationJob
  queue_as :heavy

  METRIC_NAME = "uphold_kyc_by_country_job".freeze
  UPHOLD_CONNECTION_KYCD_BY_COUNTRY = "uphold_connection.kycd_by_country".freeze
  UPHOLD_CONNECTION_INITIAL_FUNNEL_BY_COUNTRY = "uphold_connection.initial_funnel_by_country".freeze

  def perform
    DailyMetric.create(
      name: UPHOLD_CONNECTION_KYCD_BY_COUNTRY,
      result: kycd_by_country,
      date: Date.today
    )
    DailyMetric.create(
      name: UPHOLD_CONNECTION_INITIAL_FUNNEL_BY_COUNTRY,
      result: initial_funnel_by_country,
      date: Date.today
    )
  end

=begin
  Uphold Connections
=end
  def initial_funnel_by_country
    results = {}
    ActiveRecord::Base.connection.execute("
        select count(id), country
        from uphold_connections
        group by country
        order by count(*) desc").each do |entry|
      results[entry['country'] || "n/a"] = entry['count']
    end
    results
  end

  def kycd_by_country
    results = {}
    ActiveRecord::Base.connection.execute("
        select count(id), country
        from uphold_connections
        where is_member = true
        group by country
        order by count(*) desc").each do |entry|
      results[entry['country'] || "n/a"] = entry['count']
    end
    results
  end
end
