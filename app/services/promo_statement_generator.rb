# Creates a statement to be converted into tables and downloaded by admins
class PromoStatementGenerator < BaseService
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

    # Build the statement contents
    statement_contents = {}
    promo_registrations.each do |promo_registration|
      # Pull all statistics associated with a code
      events = JSON.parse(promo_registration.stats)

      # Select only those within date range supplied
      events_within_statement_period = events.select { |event|
        (event["ymd"].to_date >= @start_date) && (event["ymd"].to_date <= @end_date)
      }

      if @reporting_interval == "cumulative"
        base_case = {"retrievals" => 0, "first_runs" => 0, "finalized" => 0 }
        culmative_statement_contents = events_within_statement_period.reduce(base_case) { |aggregate_stats, event|
          aggregate_stats["retrievals"] += event["retrievals"]
          aggregate_stats["first_runs"] += event["first_runs"]
          aggregate_stats["finalized"] += event["finalized"]
          aggregate_stats.slice("retrievals", "first_runs", "finalized")
        }

        statement_contents_for_referral_code = {
          @start_date => culmative_statement_contents
        }

        statement_contents["#{promo_registration.referral_code}"] = statement_contents_for_referral_code
      else
        statement_contents_for_referral_code = empty_statement_contents_for_referral_code(@start_date, @end_date, @reporting_interval)
        events_within_statement_period.each do |event|
          interval_start_date = coerce_date_to_start_or_end_of_reporting_interval(event["ymd"].to_date, @reporting_interval, true)
          existing_event = statement_contents_for_referral_code[interval_start_date]
          existing_event["retrievals"] += event["retrievals"]
          existing_event["first_runs"] += event["first_runs"]
          existing_event["finalized"] += event["finalized"]
        end
        statement_contents["#{promo_registration.referral_code}"] = statement_contents_for_referral_code
      end
    end
    #
    # Example statement_contents:
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

    statement_hash = {
      "contents" => statement_contents,
      "start_date" => "#{@start_date}",
      "end_date" => "#{@end_date}"
   }
  end

  private

  # Creates a statement_contents for a single referral code with all 0 values
  def empty_statement_contents_for_referral_code(start_date, end_date, reporting_interval)
    statement_contents_for_referral_code = {}
    current_date = start_date
    while current_date <= end_date do 
      statement_contents_for_referral_code[current_date] = {
        "retrievals" => 0,
        "first_runs" => 0,
        "finalized" => 0
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
    statement_contents_for_referral_code
  end
end