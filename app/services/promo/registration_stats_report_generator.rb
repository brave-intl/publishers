# Creates a report to be converted into tables and downloaded by admins
class Promo::RegistrationStatsReportGenerator < BaseService
  include PromosHelper

  def initialize(referral_codes:, start_date:, end_date:, reporting_interval:, geo:)
    @referral_codes = referral_codes
    @start_date = coerce_date_to_start_or_end_of_reporting_interval(start_date, reporting_interval, true)
    @end_date = coerce_date_to_start_or_end_of_reporting_interval(end_date, reporting_interval, false)
    @reporting_interval = reporting_interval
    @geo = geo
  end

  def perform
    report_contents = {}

    events = fetch_stats
    events = select_events_within_report_range(events)
    events = fill_in_events_with_no_activity(@referral_codes, events)

    events_by_referral_codes = group_events_by_referral_code(events)

    events_by_referral_codes.each do |referral_code, events|
      events = order_events_by_date(events)
      events_by_referral_code_for_interval = group_events_by_date(events)

      # Sum the events per interval, or per interval per country if @geo
      per_interval_totals = {}
      events_by_referral_code_for_interval.each do |date, events|
        if @geo
          events_by_referral_code_for_interval_by_country = group_events_by_country(events)

          per_country_totals = {}
          events_by_referral_code_for_interval_by_country.each do |country, events|
            per_country_totals[country] = sum_totals(events)
          end

          # If there are any events for any country other than N/A, remove the blank country data
          per_country_totals.delete("N/A") if per_country_totals.keys.count > 1
          per_interval_totals[date] = per_country_totals            
        else
          per_interval_totals[date] = sum_totals(events)
        end
      end
      report_contents[referral_code] = per_interval_totals
    end

    {
      "contents" => report_contents,
      "start_date" => "#{@start_date}",
      "end_date" => "#{@end_date}"
    }
  end

  private

  def group_events_by_country(events)
    events = events.group_by do |event|
      event["country"]
    end
  end

  def order_events_by_date(events)
    events.sort_by do |event|
      event["ymd"].to_date
    end
  end

  def group_events_by_referral_code(events)
    events_by_referral_codes = events.group_by do |event|
      event["referral_code"]
    end
  end

  def fetch_stats
    if @geo
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

  def sum_totals(events)
    totals = {
      PromoRegistration::RETRIEVALS => 0,
      PromoRegistration::FIRST_RUNS => 0,
      PromoRegistration::FINALIZED => 0
    }

    events.each do |event|
      totals[PromoRegistration::RETRIEVALS] += event[PromoRegistration::RETRIEVALS]
      totals[PromoRegistration::FIRST_RUNS] += event[PromoRegistration::FIRST_RUNS]
      totals[PromoRegistration::FINALIZED] += event[PromoRegistration::FINALIZED]
    end
    totals
  end

  def fill_in_events_with_no_activity(referral_codes, events)
    blank_events = []
    current_date = @start_date
    while current_date <= @end_date
      referral_codes.each do |referral_code|
        blank_events.push({
          "referral_code" => referral_code,
          "ymd" => current_date.strftime("%Y-%m-%d"),
          "country" => "N/A",
          PromoRegistration::RETRIEVALS => 0,
          PromoRegistration::FIRST_RUNS => 0,
          PromoRegistration::FINALIZED => 0,
        })
      end
      current_date = current_date + 1.day
    end

    events + blank_events
  end
end
