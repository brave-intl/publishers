require "csv"

# Creates a report to be converted into tables and downloaded by admins
class Promo::RegistrationStatsReportGenerator < BaseService
  include PromosHelper

  def initialize(referral_codes:, start_date:, end_date:, reporting_interval:, is_geo:)
    @referral_codes = referral_codes
    @start_date = coerce_date_to_start_or_end_of_reporting_interval(start_date, reporting_interval, true)
    @end_date = coerce_date_to_start_or_end_of_reporting_interval(end_date, reporting_interval, false)
    @reporting_interval = reporting_interval
    @is_geo = is_geo
  end

  def perform
    events = fetch_stats
    events = select_events_within_report_range(events)
    events = fill_in_events_with_no_activity(events)

    ratios = []

    CSV.generate do |csv|
      csv << column_headers

      group_by_referral_code(events).each do |referral_code, referrals|
        group_by_country(referrals).each do |country, grouped_country|
          group_by_date(grouped_country).each do |date, grouped_dates|
            csv << reduce_events(grouped_dates, referral_code, country, date)
          end

          ratios << calculate_ratios(referral_code, country, grouped_country)
        end
      end

      # Append newline and ratio headers to the CSV generated
      csv << [] << ratios_column_header(broken_down_by_country?)
      ratios.each do |ratio|
        csv << ratio
      end
    end
  end

  private

  def broken_down_by_country?
    @is_geo
  end

  def column_headers
    headers = [
      "Referral code",
      "Country",
      reporting_interval_column_header(@reporting_interval),
      event_type_column_header(PromoRegistration::RETRIEVALS),
      event_type_column_header(PromoRegistration::FIRST_RUNS),
      event_type_column_header(PromoRegistration::FINALIZED),
    ]

    headers.delete("Country") unless broken_down_by_country?

    headers
  end

  def calculate_ratios(referral_code, country, events)
    total_downloads = events.sum { |e| e[PromoRegistration::RETRIEVALS] } || 0
    total_installs = events.sum { |e| e[PromoRegistration::FIRST_RUNS] } || 0

    # An install is eligible when at least 30 days have passed
    # We don't want to report 30 days / install ratio, if 30 days
    # haven't passed since install time
    total_eligible_installs = events.select do |event|
      (Time.now.utc.to_date - 1.month) >= event["ymd"].to_date
    end

    total_eligible_installs = total_eligible_installs.sum { |e| e[PromoRegistration::FIRST_RUNS] }
    total_eligible_installs ||= 0.0

    total_30_days = events.sum { |e| e[PromoRegistration::FINALIZED] } || 0

    install_to_download_ratio = (total_installs.to_f / total_downloads.to_f).round(2)
    install_to_30_days_ratio = (total_30_days.to_f / total_eligible_installs.to_f).round(2)

    install_to_download_ratio = 0 if install_to_download_ratio.nan?
    install_to_30_days_ratio = 0 if install_to_30_days_ratio.nan?

    ratios = [
      referral_code,
      country,
      total_downloads,
      total_installs,
      total_eligible_installs,
      total_30_days,
      install_to_download_ratio,
      install_to_30_days_ratio,
    ]

    # Delete the country from the array unless it's we're currently looking for geography information
    ratios.delete_at(1) unless broken_down_by_country?

    ratios
  end

  def reduce_events(events, referral_code, country, date)
    combined = {
      referral_code: referral_code,
      country: country,
      ymd: date.to_s,
      retrievals: 0,
      first_runs: 0,
      finalized: 0,
    }

    events.each do |event|
      combined[:retrievals] += event[PromoRegistration::RETRIEVALS]
      combined[:first_runs] += event[PromoRegistration::FIRST_RUNS]
      combined[:finalized] += event[PromoRegistration::FINALIZED]
    end

    combined.delete(:country) unless broken_down_by_country?

    combined.values
  end

  def group_by_country(events)
    return { nil => events } unless broken_down_by_country?

    events.sort_by do |event|
      event[PromoRegistration::COUNTRY] || ""
    end.group_by do |event|
      event[PromoRegistration::COUNTRY]
    end
  end

  def group_by_referral_code(events)
    events.group_by { |e| e["referral_code"] }
  end

  def fetch_stats
    return geo_stats if broken_down_by_country?

    Promo::RegistrationsStatsFetcher.new(promo_registrations: PromoRegistration.where(referral_code: @referral_codes)).perform
  end

  def geo_stats
    PromoClient.reporting.geo_stats_by_referral_code(
      referral_codes: @referral_codes,
      start_date: @start_date,
      end_date: @start_date,
      interval: @reporting_interval
    )
  end

  def select_events_within_report_range(events)
    events.select do |event|
      (event["ymd"].to_date >= @start_date) && (event["ymd"].to_date <= @end_date)
    end
  end

  # Internal: Given a set of events, groups the events by the options provided in the UI
  #
  # events - A hash of events
  #
  # Examples
  #
  #   @reporting_interval = PromoRegistration::RUNNING_TOTAL
  #   group_by_date([{ "ymd"=>"2019-10-14", "retrievals" => 1 }, { "ymd"=>"2019-10-15", "retrievals" => 1 }])
  #
  #   Returns
  #   {
  #     "2010-10-31" => [{ "ymd"=>"2019-10-14", "retrievals" => 1 }, { "ymd"=>"2019-10-15", "retrievals" => 1 }]
  #   }
  #
  # Returns an array hash of the events
  def group_by_date(events)
    events = events.sort_by { |event| event["ymd"].to_date }
    events_by_interval = events.group_by do |event|
      case @reporting_interval
      when PromoRegistration::DAILY
        event["ymd"].to_date
      when PromoRegistration::WEEKLY
        event["ymd"].to_date.at_beginning_of_week
      when PromoRegistration::MONTHLY
        event["ymd"].to_date.at_beginning_of_month
      when PromoRegistration::RUNNING_TOTAL
        @end_date
      else
        raise "Invalid reporting interval #{@reporting_interval}."
      end
    end

    events_by_interval
  end

  def fill_in_events_with_no_activity(events)
    events_with_no_activity = []
    grouped_referrals = group_by_referral_code(events)

    (@start_date..@end_date).each do |day|
      events.map { |e| e["referral_code"] }.each do |referral_code|
        if broken_down_by_country?
          countries = grouped_referrals[referral_code].map { |e| e[PromoRegistration::COUNTRY] }.uniq
          countries.each do |country|
            events_with_no_activity.push({
              "referral_code" => referral_code,
              "country" => country,
              "ymd" => day.strftime("%Y-%m-%d"),
              PromoRegistration::RETRIEVALS => 0,
              PromoRegistration::FIRST_RUNS => 0,
              PromoRegistration::FINALIZED => 0,
            })
          end
        else
          events_with_no_activity.push({
            "referral_code" => referral_code,
            "ymd" => day.strftime("%Y-%m-%d"),
            PromoRegistration::RETRIEVALS => 0,
            PromoRegistration::FIRST_RUNS => 0,
            PromoRegistration::FINALIZED => 0,
          })
        end
      end
    end
    events + events_with_no_activity
  end
end
