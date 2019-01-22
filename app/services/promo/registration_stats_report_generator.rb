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
    events = fill_in_events_with_no_activity(@referral_codes, events)
    events_by_referral_codes = group_events_by_referral_code(events)

    ratios = []
    csv_file = CSV.generate do |csv|
      if @is_geo
        column_headers = ["Referral code",
                          "Country",
                          reporting_interval_column_header(@reporting_interval),
                          event_type_column_header(PromoRegistration::RETRIEVALS),
                          event_type_column_header(PromoRegistration::FIRST_RUNS),
                          event_type_column_header(PromoRegistration::FINALIZED)]
        csv << column_headers
        events_by_referral_codes.each do |referral_code, events_for_referral_code|
          events_for_referral_code_by_country = group_events_by_country(events_for_referral_code)        
          events_for_referral_code_by_country.each do |country, events_for_referral_code_for_country|
            events_for_referral_code_for_country_by_interval = group_events_by_date(events_for_referral_code_for_country)
            events_for_referral_code_for_country_by_interval.each do |date, events_for_referral_code_for_country_for_interval|
              combined = combine_events(events_for_referral_code_for_country_for_interval, referral_code, country, date)
              csv << [
                combined["referral_code"],
                combined[PromoRegistration::COUNTRY],
                combined["ymd"],
                combined[PromoRegistration::RETRIEVALS],
                combined[PromoRegistration::FIRST_RUNS],
                combined[PromoRegistration::FINALIZED]
              ]
            end
            ratios = ratios.append(calculate_ratios(referral_code, country, events_for_referral_code_for_country))
          end
        end
      else
        column_headers = ["Referral code",
                          reporting_interval_column_header(@reporting_interval),
                          event_type_column_header(PromoRegistration::RETRIEVALS),
                          event_type_column_header(PromoRegistration::FIRST_RUNS),
                          event_type_column_header(PromoRegistration::FINALIZED)]
        csv << column_headers
        events_by_referral_codes.each do |referral_code, events_for_referral_code|
          events_for_referral_code_by_interval = group_events_by_date(events_for_referral_code)
          events_for_referral_code_by_interval.each do |date, events_for_referral_code_for_interval|
            combined = combine_events(events_for_referral_code_for_interval, referral_code, nil, date)
            csv << [
              combined["referral_code"],
              combined["ymd"],
              combined[PromoRegistration::RETRIEVALS],
              combined[PromoRegistration::FIRST_RUNS],
              combined[PromoRegistration::FINALIZED]
            ]
          end
          ratios = ratios.append(calculate_ratios(referral_code, nil, events_for_referral_code))
        end
      end

      csv = add_ratios_column_headers(csv)
      ratios.each do |ratio|
        csv << ratio
      end
    end
  end

  private

  def calculate_ratios(referral_code, country, events_for_referral_code)
    total_downloads_for_referral_code = events_for_referral_code.sum {|event_for_referral_code| event_for_referral_code[PromoRegistration::RETRIEVALS]} || 0
    total_installs_for_referral_code = events_for_referral_code.sum {|event_for_referral_code| event_for_referral_code[PromoRegistration::FIRST_RUNS]} || 0

    # An install is eligible when at least 30 days have passed
    # We don't want to report 30 days / install ratio, if 30 days
    # haven't passed since install time
    total_eligible_installs_for_referral_code = events_for_referral_code.select { |event_for_referral_code|
      (Time.now.utc.to_date - 1.month) >= event_for_referral_code["ymd"].to_date
    }.sum { |event_for_referral_code|
      event_for_referral_code[PromoRegistration::FIRST_RUNS]
    } || 0.0

    total_30_days_for_referral_code = events_for_referral_code.sum {|event_for_referral_code| event_for_referral_code[PromoRegistration::FINALIZED]} || 0 

    install_to_download_ratio = (total_installs_for_referral_code.to_f / total_downloads_for_referral_code.to_f).round(2)
    install_to_30_days_ratio = (total_30_days_for_referral_code.to_f / total_eligible_installs_for_referral_code.to_f).round(2)

    if @is_geo
      [
        referral_code,
        country,
        total_downloads_for_referral_code,
        total_installs_for_referral_code,
        total_eligible_installs_for_referral_code,
        total_30_days_for_referral_code,
        install_to_download_ratio,
        install_to_30_days_ratio
      ]
    else
      [
        referral_code,
        total_downloads_for_referral_code,
        total_installs_for_referral_code,
        total_eligible_installs_for_referral_code,
        total_30_days_for_referral_code,
        install_to_download_ratio,
        install_to_30_days_ratio
      ]
    end
  end

  def add_ratios_column_headers(csv)
    csv << []
    csv << ratios_column_header(@is_geo)
  end

  def combine_events(events, referral_code, country, date)
    combined = {
      "referral_code"=>referral_code,
      "ymd"=>date.to_s,
      "retrievals"=>0,
      "first_runs"=>0,
      "finalized"=>0,
    }

    if @is_geo
      combined["country"] = country
    end

    events.each do |event|
      combined[PromoRegistration::RETRIEVALS] += event[PromoRegistration::RETRIEVALS]
      combined[PromoRegistration::FIRST_RUNS] += event[PromoRegistration::FIRST_RUNS]
      combined[PromoRegistration::FINALIZED] += event[PromoRegistration::FINALIZED]
    end

    combined
  end

  def group_events_by_country(events)
    events.sort_by { |event|
      event[PromoRegistration::COUNTRY] || ""
    }.group_by { |event|
      event[PromoRegistration::COUNTRY]
    }
  end

  def group_events_by_referral_code(events)
    events.sort_by { |event| 
      event["referral_code"]
    }.group_by { |event|
      event["referral_code"]
    }
  end

  def fetch_stats
    if @is_geo
      events = Promo::RegistrationsGeoStatsFetcher.new(promo_registrations: PromoRegistration.where(referral_code: @referral_codes)).perform
    else
      events = Promo::RegistrationsStatsFetcher.new(promo_registrations: PromoRegistration.where(referral_code: @referral_codes)).perform
    end
  end

  def select_events_within_report_range(events)
    events.select do |event|
      (event["ymd"].to_date >= @start_date) && (event["ymd"].to_date <= @end_date)
    end
  end

  def group_events_by_date(events)
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

  def fill_in_events_with_no_activity(referral_codes, events)
    events_with_no_activity = []
    countries = events.map { |event| event[PromoRegistration::COUNTRY] }.uniq

    (@start_date..@end_date).each do |day|
      referral_codes.each do |referral_code|
        if @is_geo
          countries.each do |country|
            events_with_no_activity.push({
              "referral_code" => referral_code,
              "ymd" => day.strftime("%Y-%m-%d"),
              PromoRegistration::COUNTRY => country,
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
