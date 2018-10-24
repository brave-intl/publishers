# Creates a report to be converted into tables and downloaded by admins
class PromoReportGenerator < BaseService
  include PromosHelper

  def initialize(referral_codes:, start_date:, end_date:, reporting_interval:)
    @referral_codes = referral_codes
    @start_date = coerce_date_to_start_or_end_of_reporting_interval(start_date, reporting_interval, true)
    @end_date = coerce_date_to_start_or_end_of_reporting_interval(end_date, reporting_interval, false)
    @reporting_interval = reporting_interval
  end

  def perform
    # Fetch the most recent stats
    promo_registrations = PromoRegistration.where(referral_code: @referral_codes)
    AdminPromoStatsFetcher.new(promo_registrations: promo_registrations).perform
    promo_registrations.reload

    # Build the report contents
    report_contents = {}
    promo_registrations.each do |promo_registration|
      # Pull all statistics associated with a code
      events = JSON.parse(promo_registration.stats)

      # Select only those within date range supplied
      events_within_report_period = events.select { |event|
        (event["ymd"].to_date >= @start_date) && (event["ymd"].to_date <= @end_date)
      }

      if @reporting_interval == "cumulative"
        base_case = {PromoRegistration::RETRIEVALS => 0, PromoRegistration::FIRST_RUNS => 0, "finalized" => 0 }
        cumulative_report_contents = events_within_report_period.reduce(base_case) { |aggregate_stats, event|
          aggregate_stats[PromoRegistration::RETRIEVALS] += event[PromoRegistration::RETRIEVALS]
          aggregate_stats[PromoRegistration::FIRST_RUNS] += event[PromoRegistration::FIRST_RUNS]
          aggregate_stats[PromoRegistration::FINALIZED] += event[PromoRegistration::FINALIZED]
          aggregate_stats.slice(PromoRegistration::RETRIEVALS, PromoRegistration::FIRST_RUNS, PromoRegistration::FINALIZED)
        }

        report_contents_for_referral_code = {
          @start_date => cumulative_report_contents
        }

        report_contents["#{promo_registration.referral_code}"] = report_contents_for_referral_code
      else
        report_contents_for_referral_code = empty_report_contents_for_referral_code(@start_date, @end_date, @reporting_interval)
        events_within_report_period.each do |event|
          interval_start_date = coerce_date_to_start_or_end_of_reporting_interval(event["ymd"].to_date, @reporting_interval, true)
          existing_event = report_contents_for_referral_code[interval_start_date]
          existing_event[PromoRegistration::RETRIEVALS] += event[PromoRegistration::RETRIEVALS]
          existing_event[PromoRegistration::FIRST_RUNS] += event[PromoRegistration::FIRST_RUNS]
          existing_event[PromoRegistration::FINALIZED] += event[PromoRegistration::FINALIZED]
        end
        report_contents["#{promo_registration.referral_code}"] = report_contents_for_referral_code
      end
    end
    #
    # Example report_contents:
    #
    # {"YYY999"=>
    #    {Sun, 01 Oct 2017=>{"retrievals"=>40, "first_runs"=>33, "finalized"=>3},
    #     Wed, 01 Nov 2017=>{"retrievals"=>45, "first_runs"=>30, "finalized"=>3},
    #     Fri, 01 Dec 2017=>{"retrievals"=>30, "first_runs"=>19, "finalized"=>4},
    #     Mon, 01 Jan 2018=>{"retrievals"=>34, "first_runs"=>20, "finalized"=>6},
    #     Thu, 01 Feb 2018=>{"retrievals"=>25, "first_runs"=>19, "finalized"=>5}},
    # "ZZZ000"=>
    #    {Sun, 01 Oct 2017=>{"retrievals"=>4, "first_runs"=>2, "finalized"=>0},
    #     Wed, 01 Nov 2017=>{"retrievals"=>3, "first_runs"=>1, "finalized"=>0},
    #     Fri, 01 Dec 2017=>{"retrievals"=>2, "first_runs"=>0, "finalized"=>0},
    #     Mon, 01 Jan 2018=>{"retrievals"=>1, "first_runs"=>0, "finalized"=>1},
    #     Thu, 01 Feb 2018=>{"retrievals"=>2, "first_runs"=>2, "finalized"=>1}}
    # 
    # The dates indicate the the start date of a reporting interval.
    # In this case the reporting interval is 'by_month'.
    #
    # If the reporting interval is 'cumulative', then there is only one reporting interval,
    # the beginning on the period start_date. e.g:
    #
    # {"XEN116"=>
    #   {Sun, 22 Oct 2017=>{"retrievals"=>0, "first_runs"=>1679, "finalized"=>43}},
    #  "AAD116"=>
    #   {Sun, 22 Oct 2017=>{"retrievals"=>0, "first_runs"=>11, "finalized"=>2}}}

    report_hash = {
      "contents" => report_contents,
      "start_date" => "#{@start_date}",
      "end_date" => "#{@end_date}"
   }
  end

  private

  # Creates a report_contents for a single referral code with all 0 values
  def empty_report_contents_for_referral_code(start_date, end_date, reporting_interval)
    report_contents_for_referral_code = {}
    current_date = start_date
    while current_date <= end_date do 
      report_contents_for_referral_code[current_date] = {
        PromoRegistration::RETRIEVALS => 0,
        PromoRegistration::FIRST_RUNS => 0,
        PromoRegistration::FINALIZED => 0
      }
      case reporting_interval
      when "by_day"
        current_date = current_date + 1.day
      when "by_week"
        current_date = current_date + 1.week
      when "by_month"
        current_date = current_date + 1.month
      else
        raise
      end
    end
    report_contents_for_referral_code
  end
end