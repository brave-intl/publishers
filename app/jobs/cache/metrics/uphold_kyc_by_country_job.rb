class Cache::Metrics::UpholdKycByCountryJob < ApplicationJob
  queue_as :heavy

  METRIC_NAME = "uphold_kyc_by_country_job".freeze

  def perform
    DailyMetric.create(
      name: METRIC_NAME,
      json: UpholdConnection.kycd_by_country,
      date: Date.today
    )
  end
end
