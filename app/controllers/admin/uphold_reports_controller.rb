require 'csv'

module Admin
  class UpholdReportsController < AdminController
    def index
      @uphold_report = UpholdReport.
        group('(EXTRACT(YEAR FROM created_at))::integer').
        group('(EXTRACT(MONTH FROM created_at))::integer').
        order('2 DESC, 3 DESC').count
    end

    def show
      date = DateTime.strptime(params[:id], "%Y-%m")
      start_date = date.at_beginning_of_month
      end_date = date.at_end_of_month

      @uphold_report = UpholdReport.where("created_at >= :start AND created_at <= :finish", start: start_date, finish: end_date)

      generated = []
      generated << ["publisher id", "publisher created at", "uphold id", "uphold connected time"].to_csv

      @uphold_report.each do |report|
        generated << [report.publisher_id, report.publisher.created_at, report.uphold_id, report.created_at].to_csv
      end

      send_data generated.join(''), filename: "uphold-#{params[:id]}.csv"
    end
  end
end

